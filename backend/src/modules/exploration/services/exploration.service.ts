import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { ExplorationEntity } from '../entities/exploration.entity';
import { CreateExplorationDto } from '../dto/create-exploration.dto';
import { ExplorationProgressDto } from '../dto/exploration-response.dto';
import { UsersService } from '../../users/users.service';
import { MedalsService } from '../../medals/medals.service';
import {
  GPS_ACCURACY_THRESHOLD_M,
  DEFAULT_SEARCH_RADIUS_M,
  FOG_OF_WAR_RADIUS_M,
  EXPLORATION_DEGRADATION_DAYS,
  buildWktPoint,
} from '../../../common/constants/geo.constants';
import { MasteryLevel } from '../../../common/enums/mastery-level.enum';

const SPEED_LIMIT_KMH = 20;
const BASE_XP_EXPLORATION = 10;
const AREA_INCREMENT_PER_POINT = 0.5;

@Injectable()
export class ExplorationService {
  constructor(
    @InjectRepository(ExplorationEntity)
    private explorationRepository: Repository<ExplorationEntity>,
    private usersService: UsersService,
    private medalsService: MedalsService,
  ) {}

  async registerExploration(
    userId: string,
    createExplorationDto: CreateExplorationDto,
  ): Promise<ExplorationProgressDto> {
    if (
      createExplorationDto.speed_kmh &&
      createExplorationDto.speed_kmh > SPEED_LIMIT_KMH
    ) {
      throw new BadRequestException(
        `Speed limit exceeded. Max speed: ${SPEED_LIMIT_KMH} km/h`,
      );
    }

    const accuracy =
      createExplorationDto.accuracy_meters ?? GPS_ACCURACY_THRESHOLD_M;
    if (accuracy > GPS_ACCURACY_THRESHOLD_M) {
      throw new BadRequestException(
        `GPS accuracy too low. Required: < ${GPS_ACCURACY_THRESHOLD_M}m`,
      );
    }

    const user = await this.usersService.findByIdOrThrow(userId);

    const newArea = await this.isNewArea(
      userId,
      createExplorationDto.latitude,
      createExplorationDto.longitude,
    );

    const exploration = this.explorationRepository.create({
      user_id: userId,
      latitude: createExplorationDto.latitude,
      longitude: createExplorationDto.longitude,
      accuracy_meters: accuracy,
      speed_kmh: createExplorationDto.speed_kmh ?? 0,
      location: buildWktPoint(
        createExplorationDto.longitude,
        createExplorationDto.latitude,
      ),
    });

    await this.explorationRepository.save(exploration);

    const newAreaPercent = newArea
      ? this.calculateNewAreas(user.exploration_percent)
      : 0;
    const xpEarned = Math.floor(newAreaPercent * BASE_XP_EXPLORATION);

    const newExplorationPercent = Math.min(
      user.exploration_percent + newAreaPercent,
      100,
    );
    const newTotalXp = user.total_xp + xpEarned;

    await this.usersService.updateExplorationStats(
      userId,
      newExplorationPercent,
      newTotalXp,
    );

    await this.medalsService.checkAndAwardMedals(userId);

    return {
      user_id: userId,
      exploration_percent: newExplorationPercent,
      total_xp: newTotalXp,
      new_areas_cleared: newAreaPercent,
      xp_earned: xpEarned,
      fog_updated: true,
      districts_explored: this.getDistrictExploration(),
    };
  }

  async getExplorationProgress(
    userId: string,
  ): Promise<ExplorationProgressDto> {
    const user = await this.usersService.findByIdOrThrow(userId);

    return {
      user_id: userId,
      exploration_percent: user.exploration_percent,
      total_xp: user.total_xp,
      new_areas_cleared: 0,
      xp_earned: 0,
      fog_updated: false,
      districts_explored: this.getDistrictExploration(),
    };
  }

  async getMapWithFog(
    userId: string,
    latitude: number,
    longitude: number,
    radiusMeters: number = DEFAULT_SEARCH_RADIUS_M,
  ) {
    const cutoffDate = this.getActiveCutoffDate();

    const explorations = await this.explorationRepository
      .createQueryBuilder('e')
      .select(['e.latitude', 'e.longitude', 'e.explored_at'])
      .where('e.user_id = :userId', { userId })
      .andWhere('e.explored_at >= :cutoff', { cutoff: cutoffDate })
      .andWhere(
        'ST_DWithin(e.location::geography, ST_MakePoint(:lng, :lat)::geography, :radius)',
        { lng: longitude, lat: latitude, radius: radiusMeters },
      )
      .orderBy('e.explored_at', 'DESC')
      .getRawMany();

    const features = (
      explorations as Array<{
        e_latitude: number;
        e_longitude: number;
        e_explored_at: string;
      }>
    ).map(exp => ({
      type: 'Feature' as const,
      geometry: {
        type: 'Point' as const,
        coordinates: [exp.e_longitude, exp.e_latitude],
      },
      properties: {
        timestamp: exp.e_explored_at,
      },
    }));

    const user = await this.usersService.findById(userId);

    return {
      fog_of_war: {
        type: 'FeatureCollection' as const,
        features,
      },
      points_of_interest: await this.getNearbyPOIs(latitude, longitude),
      user_position: { latitude, longitude },
      exploration_percent: user?.exploration_percent ?? 0,
    };
  }

  async getLastExploration(userId: string): Promise<ExplorationEntity | null> {
    return await this.explorationRepository.findOne({
      where: { user_id: userId },
      order: { explored_at: 'DESC' },
    });
  }

  async getExplorationHistory(
    userId: string,
    limit: number = 50,
    offset: number = 0,
  ): Promise<{ data: ExplorationEntity[]; total: number }> {
    const [data, total] = await this.explorationRepository.findAndCount({
      where: { user_id: userId },
      order: { explored_at: 'DESC' },
      take: limit,
      skip: offset,
    });

    return { data, total };
  }

  async getExplorationStats(
    userId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<{
    total_explorations: number;
    unique_locations: number;
    distance_km: number;
    time_hours: number;
  }> {
    const [, total_explorations] =
      await this.explorationRepository.findAndCount({
        where: {
          user_id: userId,
          explored_at: Between(startDate, endDate),
        },
      });

    return {
      total_explorations,
      unique_locations: total_explorations,
      distance_km: 0,
      time_hours: 0,
    };
  }

  @Cron(CronExpression.EVERY_DAY_AT_1AM)
  async recalculateExpiredExplorations(): Promise<void> {
    const users = await this.usersService.findAllWithExploration();
    const cutoffDate = this.getActiveCutoffDate();

    for (const user of users) {
      const activeCount = await this.explorationRepository.count({
        where: {
          user_id: user.id,
          explored_at: MoreThanOrEqual(cutoffDate),
        },
      });

      const newPercent = Math.min(activeCount * AREA_INCREMENT_PER_POINT, 100);
      if (newPercent !== Number(user.exploration_percent)) {
        await this.usersService.updateExplorationStats(
          user.id,
          newPercent,
          user.total_xp,
        );
      }
    }
  }

  private getActiveCutoffDate(): Date {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - EXPLORATION_DEGRADATION_DAYS);
    return cutoff;
  }

  private async isNewArea(
    userId: string,
    latitude: number,
    longitude: number,
  ): Promise<boolean> {
    const count = await this.explorationRepository
      .createQueryBuilder('e')
      .where('e.user_id = :userId', { userId })
      .andWhere(
        'ST_DWithin(e.location::geography, ST_MakePoint(:lng, :lat)::geography, :radius)',
        { lng: longitude, lat: latitude, radius: FOG_OF_WAR_RADIUS_M },
      )
      .getCount();
    return count === 0;
  }

  private calculateNewAreas(currentPercent: number): number {
    if (currentPercent >= 100) return 0;
    return Math.min(AREA_INCREMENT_PER_POINT, 100 - currentPercent);
  }

  private getDistrictExploration(): Array<{
    district_id: string;
    name: string;
    exploration_percent: number;
    mastery_level: MasteryLevel;
  }> {
    // TODO: implement PostGIS district-level aggregation
    return [];
  }

  private async getNearbyPOIs(
    _latitude: number,
    _longitude: number,
    _radiusMeters: number = DEFAULT_SEARCH_RADIUS_M,
  ): Promise<
    Array<{
      id: string;
      name: string;
      latitude: number;
      longitude: number;
      type: string;
    }>
  > {
    // TODO: implement POI database query
    return [];
  }
}
