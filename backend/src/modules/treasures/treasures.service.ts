import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { CacheService } from '../../cache/cache.service';
import {
  TreasureEntity,
  TreasureStatus,
  TreasureRarity,
} from './entities/treasure.entity';
import { TreasureClaimEntity } from './entities/treasure-claim.entity';
import { CreateTreasureDto } from './dto/create-treasure.dto';
import {
  TreasureDto,
  TreasurerRadarDto,
  TreasureWallOfFameDto,
} from './dto/treasure-response.dto';
import {
  GPS_ACCURACY_THRESHOLD_M,
  DEFAULT_SEARCH_RADIUS_M,
  buildGeoJsonPoint,
} from '../../common/constants/geo.constants';
import { GeoUtils } from '../../common/utils/geo.utils';
import { ERROR_MESSAGES } from '../../common/constants/error-messages.constants';
import { UsersService } from '../users/users.service';
import { MedalsService } from '../medals/medals.service';

const TREASURE_ACTIVATION_RADIUS_M = 100;
const TREASURE_CLAIM_RADIUS_M = 10;
const RADAR_SCAN_MULTIPLIER = 10;
const XP_DISTANCE_BONUS_WEIGHT = 0.2;
const XP_ACCURACY_BONUS_WEIGHT = 0.1;
const WALL_OF_FAME_LIMIT = 50;
// Stored as a placeholder until real GPS validation timing is implemented
const GPS_VALIDATION_STUB_MS = 3000;

const NEARBY_TTL = 900; // 15 min — invalidated on claim
const TREASURE_TTL = 1800; // 30 min
const WALL_OF_FAME_TTL = 3600; // 1 hour
const COORD_PRECISION = 10000; // round to ~11m grid for shared cache keys

const XP_BASE_REWARDS: Record<TreasureRarity, number> = {
  [TreasureRarity.COMMON]: 50,
  [TreasureRarity.UNCOMMON]: 75,
  [TreasureRarity.RARE]: 125,
  [TreasureRarity.EPIC]: 250,
  [TreasureRarity.LEGENDARY]: 500,
};

@Injectable()
export class TreasuresService {
  constructor(
    @InjectRepository(TreasureEntity)
    private treasureRepository: Repository<TreasureEntity>,
    @InjectRepository(TreasureClaimEntity)
    private claimRepository: Repository<TreasureClaimEntity>,
    private usersService: UsersService,
    private medalsService: MedalsService,
    private cache: CacheService,
  ) {}

  async createTreasure(
    userId: string,
    createTreasureDto: CreateTreasureDto,
  ): Promise<TreasureDto> {
    const treasure = this.treasureRepository.create({
      creator_id: userId,
      ...createTreasureDto,
      current_uses: 0,
      location: buildGeoJsonPoint(
        createTreasureDto.longitude,
        createTreasureDto.latitude,
      ),
    });

    const saved = await this.treasureRepository.save(treasure);
    return this.mapToDtoSync(saved, false);
  }

  async getTreasuresNearby(
    userLat: number,
    userLng: number,
    radius: number = DEFAULT_SEARCH_RADIUS_M,
    userId?: string,
  ): Promise<TreasureDto[]> {
    const lat = Math.round(userLat * COORD_PRECISION) / COORD_PRECISION;
    const lng = Math.round(userLng * COORD_PRECISION) / COORD_PRECISION;
    const cacheKey = `treasures:nearby:${lat}:${lng}:${radius}`;

    let baseDtos = await this.cache.get<TreasureDto[]>(cacheKey);

    if (!baseDtos) {
      const treasures = await this.treasureRepository
        .createQueryBuilder('t')
        .where(`ST_DWithin(t.location, ST_MakePoint(:lng, :lat), :radius)`, {
          lat: userLat,
          lng: userLng,
          radius,
        })
        .andWhere('t.status = :status', { status: TreasureStatus.ACTIVE })
        .orderBy(`ST_Distance(t.location, ST_MakePoint(:lng, :lat))`, 'ASC')
        .setParameters({ lat: userLat, lng: userLng })
        .getMany();

      baseDtos = treasures.map(t => this.mapToDtoSync(t, false));
      await this.cache.set(cacheKey, baseDtos, NEARBY_TTL);
    }

    if (!userId || baseDtos.length === 0) return baseDtos;

    // Cheap per-user claimed check — spatial query is already cached above
    const claims = await this.claimRepository.findBy({
      user_id: userId,
      treasure_id: In(baseDtos.map(t => t.id)),
    });
    const claimedIds = new Set(claims.map(c => c.treasure_id));

    return baseDtos.map(t => ({ ...t, claimed_by_user: claimedIds.has(t.id) }));
  }

  async getTreasureById(
    treasureId: string,
    userId?: string,
  ): Promise<TreasureDto> {
    const cacheKey = `treasure:${treasureId}`;
    const cached = await this.cache.get<TreasureDto>(cacheKey);

    if (cached) {
      if (!userId) return cached;
      const claimed = !!(await this.claimRepository.findOneBy({
        user_id: userId,
        treasure_id: treasureId,
      }));
      return { ...cached, claimed_by_user: claimed };
    }

    const treasure = await this.treasureRepository.findOneBy({
      id: treasureId,
    });
    if (!treasure) {
      throw new NotFoundException(ERROR_MESSAGES.TREASURE_NOT_FOUND);
    }

    const baseDto = this.mapToDtoSync(treasure, false);
    await this.cache.set(cacheKey, baseDto, TREASURE_TTL);

    return this.mapToDto(treasure, userId);
  }

  async getRadarData(
    userLat: number,
    userLng: number,
    userId: string,
  ): Promise<TreasurerRadarDto[]> {
    const treasures = await this.getTreasuresNearby(
      userLat,
      userLng,
      TREASURE_ACTIVATION_RADIUS_M * RADAR_SCAN_MULTIPLIER,
      userId,
    );

    return treasures.map(treasure => {
      const distance = GeoUtils.calculateDistance(
        userLat,
        userLng,
        treasure.latitude,
        treasure.longitude,
      );

      return {
        treasure_id: treasure.id,
        title: treasure.title,
        latitude: treasure.latitude,
        longitude: treasure.longitude,
        rarity: treasure.rarity,
        distance_meters: distance,
        bearing_degrees: GeoUtils.calculateBearing(
          userLat,
          userLng,
          treasure.latitude,
          treasure.longitude,
        ),
        proximity_percent: Math.min(
          100,
          Math.max(0, 100 - (distance / TREASURE_ACTIVATION_RADIUS_M) * 100),
        ),
        can_claim: distance <= TREASURE_CLAIM_RADIUS_M,
      };
    });
  }

  async claimTreasure(
    userId: string,
    treasureId: string,
    userLat: number,
    userLng: number,
    userAccuracy: number,
  ): Promise<{ treasure: TreasureDto; xpEarned: number; claimed: boolean }> {
    const treasure = await this.treasureRepository.findOneBy({
      id: treasureId,
    });
    if (!treasure) {
      throw new NotFoundException(ERROR_MESSAGES.TREASURE_NOT_FOUND);
    }

    if (treasure.status !== TreasureStatus.ACTIVE) {
      throw new BadRequestException('Treasure is not active');
    }

    const distance = GeoUtils.calculateDistance(
      userLat,
      userLng,
      treasure.latitude,
      treasure.longitude,
    );

    if (distance > TREASURE_CLAIM_RADIUS_M) {
      throw new BadRequestException(
        `Too far from treasure. Distance: ${distance.toFixed(1)}m (Max: ${TREASURE_CLAIM_RADIUS_M}m)`,
      );
    }

    if (userAccuracy > GPS_ACCURACY_THRESHOLD_M) {
      throw new BadRequestException(
        `GPS accuracy insufficient. Accuracy: ${userAccuracy.toFixed(1)}m (Required: < ${GPS_ACCURACY_THRESHOLD_M}m)`,
      );
    }

    const existingClaim = await this.claimRepository.findOneBy({
      user_id: userId,
      treasure_id: treasureId,
    });

    if (existingClaim) {
      throw new BadRequestException('You have already claimed this treasure');
    }

    const xpEarned = this.calculateClaimXp(
      treasure.rarity,
      distance,
      userAccuracy,
    );

    const claim = this.claimRepository.create({
      user_id: userId,
      treasure_id: treasureId,
      xp_earned: xpEarned,
      distance_meters: distance,
      gps_validation_time_ms: GPS_VALIDATION_STUB_MS,
    });

    await this.claimRepository.save(claim);

    treasure.current_uses += 1;
    if (treasure.max_uses && treasure.current_uses >= treasure.max_uses) {
      treasure.status = TreasureStatus.DEPLETED;
    }
    await this.treasureRepository.save(treasure);

    await this.usersService.addXp(userId, xpEarned);
    await this.medalsService.checkAndAwardMedals(userId);

    await Promise.all([
      this.cache.del(`treasure:${treasureId}`),
      this.cache.delPattern('treasures:nearby:*'),
    ]);

    return {
      treasure: this.mapToDtoSync(treasure, true),
      xpEarned,
      claimed: true,
    };
  }

  async getTreasureWallOfFame(
    treasureId: string,
  ): Promise<TreasureWallOfFameDto[]> {
    const cacheKey = `treasure:wof:${treasureId}`;
    const cached = await this.cache.get<TreasureWallOfFameDto[]>(cacheKey);
    if (cached) return cached;

    const claims = await this.claimRepository
      .createQueryBuilder('tc')
      .leftJoinAndSelect('tc.user', 'u')
      .where('tc.treasure_id = :treasureId', { treasureId })
      .orderBy('tc.claimed_at', 'DESC')
      .limit(WALL_OF_FAME_LIMIT)
      .getMany();

    const result = claims.map(claim => ({
      id: claim.user.id,
      username: claim.user.username,
      claimed_at: claim.claimed_at,
      xp_earned: claim.xp_earned,
      distance_meters: claim.distance_meters,
      gps_validation_time_ms: claim.gps_validation_time_ms,
    }));

    await this.cache.set(cacheKey, result, WALL_OF_FAME_TTL);
    return result;
  }

  async getTreasureClaimsStats(userId: string): Promise<{
    total_claimed: number;
    total_xp: number;
    by_rarity: Record<TreasureRarity, number>;
  }> {
    const claims = await this.claimRepository
      .createQueryBuilder('tc')
      .leftJoinAndSelect('tc.treasure', 't')
      .where('tc.user_id = :userId', { userId })
      .getMany();

    const byRarity: Record<TreasureRarity, number> = {
      [TreasureRarity.COMMON]: 0,
      [TreasureRarity.UNCOMMON]: 0,
      [TreasureRarity.RARE]: 0,
      [TreasureRarity.EPIC]: 0,
      [TreasureRarity.LEGENDARY]: 0,
    };

    let totalXp = 0;
    claims.forEach(claim => {
      byRarity[claim.treasure.rarity]++;
      totalXp += claim.xp_earned;
    });

    return {
      total_claimed: claims.length,
      total_xp: totalXp,
      by_rarity: byRarity,
    };
  }

  private calculateClaimXp(
    rarity: TreasureRarity,
    distance: number,
    userAccuracy: number,
  ): number {
    const baseXp = XP_BASE_REWARDS[rarity];
    const distanceBonus = Math.max(
      0,
      (TREASURE_CLAIM_RADIUS_M - distance) / TREASURE_CLAIM_RADIUS_M,
    );
    const accuracyBonus =
      (GPS_ACCURACY_THRESHOLD_M - userAccuracy) / GPS_ACCURACY_THRESHOLD_M;
    const xpMultiplier =
      1 +
      distanceBonus * XP_DISTANCE_BONUS_WEIGHT +
      accuracyBonus * XP_ACCURACY_BONUS_WEIGHT;
    return Math.round(baseXp * xpMultiplier);
  }

  private mapToDtoSync(
    treasure: TreasureEntity,
    claimed: boolean,
  ): TreasureDto {
    return {
      id: treasure.id,
      title: treasure.title,
      description: treasure.description,
      latitude: treasure.latitude,
      longitude: treasure.longitude,
      status: treasure.status,
      rarity: treasure.rarity,
      max_uses: treasure.max_uses,
      current_uses: treasure.current_uses,
      uses_remaining: treasure.max_uses
        ? treasure.max_uses - treasure.current_uses
        : 0,
      photo_url: treasure.photo_url,
      stl_file_url: treasure.stl_file_url,
      claimed_by_user: claimed,
      created_at: treasure.created_at,
      updated_at: treasure.updated_at,
    };
  }

  private async mapToDto(
    treasure: TreasureEntity,
    userId?: string,
  ): Promise<TreasureDto> {
    let claimed = false;
    if (userId) {
      claimed = !!(await this.claimRepository.findOneBy({
        user_id: userId,
        treasure_id: treasure.id,
      }));
    }
    return this.mapToDtoSync(treasure, claimed);
  }
}
