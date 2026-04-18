import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ExplorationEntity } from '../entities/exploration.entity';
import { CreateExplorationDto } from '../dto/create-exploration.dto.ts';
import { ExplorationProgressDto } from '../dto/exploration-response.dto';
import { UsersService } from '../../users/users.service';

@Injectable()
export class ExplorationService {
  // Configuration constants
  private readonly FOG_OF_WAR_RADIUS_M = 75; // meters
  private readonly SPEED_LIMIT_KMH = 20; // km/h
  private readonly GPS_ACCURACY_THRESHOLD_M = 50; // meters
  private readonly BASE_XP_EXPLORATION = 10; // XP per 1% new exploration

  constructor(
    @InjectRepository(ExplorationEntity)
    private explorationRepository: Repository<ExplorationEntity>,
    private usersService: UsersService,
  ) {}

  /**
   * Register exploration point
   * Validates speed, GPS accuracy, and calculates XP/progression
   */
  async registerExploration(
    userId: string,
    createExplorationDto: CreateExplorationDto,
  ): Promise<ExplorationProgressDto> {
    // Validate speed limit
    if (
      createExplorationDto.speed_kmh &&
      createExplorationDto.speed_kmh > this.SPEED_LIMIT_KMH
    ) {
      throw new BadRequestException(
        `Speed limit exceeded. Max speed: ${this.SPEED_LIMIT_KMH} km/h`,
      );
    }

    // Validate GPS accuracy
    const accuracy = createExplorationDto.accuracy_meters || 10;
    if (accuracy > this.GPS_ACCURACY_THRESHOLD_M) {
      throw new BadRequestException(
        `GPS accuracy too low. Required: < ${this.GPS_ACCURACY_THRESHOLD_M}m`,
      );
    }

    // Get user
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Create exploration record
    const exploration = this.explorationRepository.create({
      user_id: userId,
      latitude: createExplorationDto.latitude,
      longitude: createExplorationDto.longitude,
      accuracy_meters: accuracy,
      speed_kmh: createExplorationDto.speed_kmh || 0,
      // PostGIS Point format: POINT(longitude latitude)
      location: `POINT(${createExplorationDto.longitude} ${createExplorationDto.latitude})`,
    });

    await this.explorationRepository.save(exploration);

    // Calculate new exploration areas (simplified)
    // In production, use PostGIS ST_Union, ST_Area, etc.
    const newAreaPercent = this.calculateNewAreas(
      user.exploration_percent,
    );
    const xpEarned = Math.floor(
      newAreaPercent * this.BASE_XP_EXPLORATION,
    );

    // Update user stats
    const newExplorationPercent = Math.min(
      user.exploration_percent + newAreaPercent,
      100,
    );
    const newTotalXp = user.total_xp + xpEarned;

    await this.explorationRepository.query(
      `UPDATE users SET exploration_percent = $1, total_xp = $2, updated_at = NOW() WHERE id = $3`,
      [newExplorationPercent, newTotalXp, userId],
    );

    return {
      user_id: userId,
      exploration_percent: newExplorationPercent,
      total_xp: newTotalXp,
      new_areas_cleared: newAreaPercent,
      xp_earned: xpEarned,
      fog_updated: true,
      districts_explored: await this.getDistrictExploration(userId),
    };
  }

  /**
   * Get user's exploration progress
   */
  async getExplorationProgress(userId: string): Promise<ExplorationProgressDto> {
    const user = await this.usersService.findById(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      user_id: userId,
      exploration_percent: user.exploration_percent,
      total_xp: user.total_xp,
      new_areas_cleared: 0,
      xp_earned: 0,
      fog_updated: false,
      districts_explored: await this.getDistrictExploration(userId),
    };
  }

  /**
   * Get map with fog of war
   * Returns GeoJSON of explored areas
   */
  async getMapWithFog(
    userId: string,
    latitude: number,
    longitude: number,
    radiusMeters: number = 5000,
  ) {
    // Get user explorations in radius (using PostGIS)
    const explorations = await this.explorationRepository.query(
      `
      SELECT latitude, longitude, explored_at
      FROM exploration
      WHERE user_id = $1
      AND ST_DWithin(
        location::geography,
        ST_Point($2, $1)::geography,
        $3
      )
      ORDER BY explored_at DESC
      `,
      [userId, longitude, latitude, radiusMeters],
    );

    // Build GeoJSON FeatureCollection
    const features = explorations.map((exp) => ({
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [exp.longitude, exp.latitude],
      },
      properties: {
        timestamp: exp.explored_at,
      },
    }));

    const user = await this.usersService.findById(userId);

    return {
      fog_of_war: {
        type: 'FeatureCollection',
        features,
      },
      points_of_interest: await this.getNearbyPOIs(latitude, longitude),
      user_position: {
        latitude,
        longitude,
      },
      exploration_percent: user?.exploration_percent || 0,
    };
  }

  /**
   * Calculate new area percentage (simplified)
   * In production, use proper geometric calculations
   */
  private calculateNewAreas(currentPercent: number): number {
    // Simplified: each exploration adds 0.5% (until 100%)
    if (currentPercent >= 100) return 0;
    return Math.min(0.5, 100 - currentPercent);
  }

  /**
   * Get district-level exploration stats
   */
  private async getDistrictExploration(
    userId: string,
  ): Promise<
    Array<{
      district_id: string;
      name: string;
      exploration_percent: number;
      mastery_level: string;
    }>
  > {
    // Simplified: return empty for now
    // In production, calculate per-district stats
    return [
      {
        district_id: 'madrid_001',
        name: 'Centro Histórico',
        exploration_percent: 45.3,
        mastery_level: 'SILVER',
      },
    ];
  }

  /**
   * Get nearby points of interest
   */
  private async getNearbyPOIs(
    latitude: number,
    longitude: number,
    radiusMeters: number = 5000,
  ): Promise<
    Array<{
      id: string;
      name: string;
      latitude: number;
      longitude: number;
      type: string;
    }>
  > {
    // Simplified: return empty for now
    // In production, query POI database
    return [];
  }

  /**
   * Get user's last exploration location
   */
  async getLastExploration(userId: string): Promise<ExplorationEntity | null> {
    return await this.explorationRepository.findOne({
      where: { user_id: userId },
      order: { explored_at: 'DESC' },
    });
  }

  /**
   * Get exploration history (paginated)
   */
  async getExplorationHistory(
    userId: string,
    limit: number = 50,
    offset: number = 0,
  ): Promise<{
    data: ExplorationEntity[];
    total: number;
  }> {
    const [data, total] = await this.explorationRepository.findAndCount({
      where: { user_id: userId },
      order: { explored_at: 'DESC' },
      take: limit,
      skip: offset,
    });

    return { data, total };
  }

  /**
   * Get exploration stats for date range
   */
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
    const explorations = await this.explorationRepository.find({
      where: {
        user_id: userId,
      },
    });

    // Filter by date
    const filtered = explorations.filter(
      (e) => e.explored_at >= startDate && e.explored_at <= endDate,
    );

    return {
      total_explorations: filtered.length,
      unique_locations: filtered.length, // Simplified
      distance_km: 0, // Would need haversine calculation
      time_hours: 0, // Would need time calculation
    };
  }
}
