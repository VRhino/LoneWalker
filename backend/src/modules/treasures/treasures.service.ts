import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TreasureEntity, TreasureStatus, TreasureRarity } from './entities/treasure.entity';
import { TreasureClaimEntity } from './entities/treasure-claim.entity';
import { CreateTreasureDto } from './dto/create-treasure.dto';
import { TreasureDto, TreasurerRadarDto, TreasureWallOfFameDto } from './dto/treasure-response.dto';

@Injectable()
export class TreasuresService {
  private readonly TREASURE_ACTIVATION_RADIUS = 100;
  private readonly TREASURE_CLAIM_RADIUS = 10;
  private readonly XP_BASE_REWARDS = {
    [TreasureRarity.COMMON]: 50,
    [TreasureRarity.UNCOMMON]: 75,
    [TreasureRarity.RARE]: 125,
    [TreasureRarity.EPIC]: 250,
    [TreasureRarity.LEGENDARY]: 500,
  };

  constructor(
    @InjectRepository(TreasureEntity)
    private treasureRepository: Repository<TreasureEntity>,
    @InjectRepository(TreasureClaimEntity)
    private claimRepository: Repository<TreasureClaimEntity>,
  ) {}

  async createTreasure(
    userId: string,
    createTreasureDto: CreateTreasureDto,
  ): Promise<TreasureDto> {
    const treasure = this.treasureRepository.create({
      creator_id: userId,
      ...createTreasureDto,
      current_uses: 0,
      location: `POINT(${createTreasureDto.longitude} ${createTreasureDto.latitude})`,
    });

    const saved = await this.treasureRepository.save(treasure);
    return this.mapToDto(saved);
  }

  async getTreasuresNearby(
    userLat: number,
    userLng: number,
    radius: number = 5000,
    userId?: string,
  ): Promise<TreasureDto[]> {
    const treasures = await this.treasureRepository
      .createQueryBuilder('t')
      .where(
        `ST_DWithin(t.location, ST_MakePoint(:lng, :lat), :radius)`,
        {
          lat: userLat,
          lng: userLng,
          radius,
        },
      )
      .andWhere('t.status = :status', { status: TreasureStatus.ACTIVE })
      .orderBy(
        `ST_Distance(t.location, ST_MakePoint(:lng, :lat))`,
        'ASC',
      )
      .setParameters({ lat: userLat, lng: userLng })
      .getMany();

    return Promise.all(
      treasures.map((t) => this.mapToDto(t, userId)),
    );
  }

  async getTreasureById(treasureId: string, userId?: string): Promise<TreasureDto> {
    const treasure = await this.treasureRepository.findOneBy({ id: treasureId });
    if (!treasure) {
      throw new NotFoundException('Treasure not found');
    }
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
      this.TREASURE_ACTIVATION_RADIUS * 10,
      userId,
    );

    return treasures.map((treasure) => {
      const distance = this.calculateDistance(
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
        bearing_degrees: this.calculateBearing(
          userLat,
          userLng,
          treasure.latitude,
          treasure.longitude,
        ),
        proximity_percent: Math.min(
          100,
          Math.max(
            0,
            100 - (distance / this.TREASURE_ACTIVATION_RADIUS) * 100,
          ),
        ),
        can_claim: distance <= this.TREASURE_CLAIM_RADIUS,
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
    const treasure = await this.treasureRepository.findOneBy({ id: treasureId });
    if (!treasure) {
      throw new NotFoundException('Treasure not found');
    }

    if (treasure.status !== TreasureStatus.ACTIVE) {
      throw new BadRequestException('Treasure is not active');
    }

    const distance = this.calculateDistance(
      userLat,
      userLng,
      treasure.latitude,
      treasure.longitude,
    );

    if (distance > this.TREASURE_CLAIM_RADIUS) {
      throw new BadRequestException(
        `Too far from treasure. Distance: ${distance.toFixed(1)}m (Max: ${this.TREASURE_CLAIM_RADIUS}m)`,
      );
    }

    if (userAccuracy > 50) {
      throw new BadRequestException(
        `GPS accuracy insufficient. Accuracy: ${userAccuracy.toFixed(1)}m (Required: < 50m)`,
      );
    }

    const existingClaim = await this.claimRepository.findOneBy({
      user_id: userId,
      treasure_id: treasureId,
    });

    if (existingClaim) {
      throw new BadRequestException('You have already claimed this treasure');
    }

    const baseXp = this.XP_BASE_REWARDS[treasure.rarity] || 50;
    const distanceBonus = Math.max(0, (this.TREASURE_CLAIM_RADIUS - distance) / this.TREASURE_CLAIM_RADIUS);
    const accuracyBonus = (50 - userAccuracy) / 50;
    const xpMultiplier = 1 + (distanceBonus * 0.2 + accuracyBonus * 0.1);
    const xpEarned = Math.round(baseXp * xpMultiplier);

    const claim = this.claimRepository.create({
      user_id: userId,
      treasure_id: treasureId,
      xp_earned: xpEarned,
      distance_meters: distance,
      gps_validation_time_ms: 3000,
    });

    await this.claimRepository.save(claim);

    treasure.current_uses += 1;

    if (treasure.max_uses && treasure.current_uses >= treasure.max_uses) {
      treasure.status = TreasureStatus.DEPLETED;
    }

    await this.treasureRepository.save(treasure);

    return {
      treasure: await this.mapToDto(treasure, userId),
      xpEarned,
      claimed: true,
    };
  }

  async getTreasureWallOfFame(treasureId: string): Promise<TreasureWallOfFameDto[]> {
    const claims = await this.claimRepository
      .createQueryBuilder('tc')
      .leftJoinAndSelect('tc.user', 'u')
      .where('tc.treasure_id = :treasureId', { treasureId })
      .orderBy('tc.claimed_at', 'DESC')
      .limit(50)
      .getMany();

    return claims.map((claim) => ({
      id: claim.user.id,
      username: claim.user.username,
      claimed_at: claim.claimed_at,
      xp_earned: claim.xp_earned,
      distance_meters: claim.distance_meters,
      gps_validation_time_ms: claim.gps_validation_time_ms,
    }));
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

    claims.forEach((claim) => {
      byRarity[claim.treasure.rarity]++;
      totalXp += claim.xp_earned;
    });

    return {
      total_claimed: claims.length,
      total_xp: totalXp,
      by_rarity: byRarity,
    };
  }

  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000;
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  private calculateBearing(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const y = Math.sin(Δλ) * Math.cos(φ2);
    const x =
      Math.cos(φ1) * Math.sin(φ2) -
      Math.sin(φ1) * Math.cos(φ2) * Math.cos(Δλ);
    const θ = Math.atan2(y, x);

    return (((θ * 180) / Math.PI + 360) % 360);
  }

  private async mapToDto(treasure: TreasureEntity, userId?: string): Promise<TreasureDto> {
    let claimed = false;
    if (userId) {
      claimed = !!(await this.claimRepository.findOneBy({
        user_id: userId,
        treasure_id: treasure.id,
      }));
    }

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
      uses_remaining: treasure.max_uses ? treasure.max_uses - treasure.current_uses : null,
      photo_url: treasure.photo_url,
      stl_file_url: treasure.stl_file_url,
      claimed_by_user: claimed,
      created_at: treasure.created_at,
      updated_at: treasure.updated_at,
    };
  }
}
