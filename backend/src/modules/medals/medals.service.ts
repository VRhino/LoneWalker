import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  MedalEntity,
  MedalKey,
  MedalRarity,
  MedalCategory,
} from './entities/medal.entity';
import { UserMedalEntity } from './entities/user-medal.entity';
import { MedalDto } from './dto/medal-response.dto';
import { UsersService } from '../users/users.service';
import { TreasureClaimEntity } from '../treasures/entities/treasure-claim.entity';
import { TreasureRarity } from '../treasures/entities/treasure.entity';
import { LandmarkVoteEntity } from '../landmarks/entities/landmark-vote.entity';
import {
  LandmarkEntity,
  LandmarkStatus,
} from '../landmarks/entities/landmark.entity';

const RARE_OR_BETTER = [
  TreasureRarity.RARE,
  TreasureRarity.EPIC,
  TreasureRarity.LEGENDARY,
];

const MEDAL_SEED: Array<{
  key: MedalKey;
  name: string;
  description: string;
  rarity: MedalRarity;
  category: MedalCategory;
  unlock_condition: string;
  xp_reward: number;
}> = [
  {
    key: MedalKey.FIRST_STEPS,
    name: 'First Steps',
    description: 'Register your first exploration point',
    rarity: MedalRarity.COMMON,
    category: MedalCategory.EXPLORATION,
    unlock_condition: 'exploration_percent >= 0.5',
    xp_reward: 50,
  },
  {
    key: MedalKey.EXPLORER_10,
    name: 'Explorer',
    description: 'Explore 10% of the city',
    rarity: MedalRarity.COMMON,
    category: MedalCategory.EXPLORATION,
    unlock_condition: 'exploration_percent >= 10',
    xp_reward: 100,
  },
  {
    key: MedalKey.EXPLORER_25,
    name: 'Seasoned Explorer',
    description: 'Explore 25% of the city',
    rarity: MedalRarity.UNCOMMON,
    category: MedalCategory.EXPLORATION,
    unlock_condition: 'exploration_percent >= 25',
    xp_reward: 200,
  },
  {
    key: MedalKey.EXPLORER_50,
    name: 'Urban Pioneer',
    description: 'Explore 50% of the city',
    rarity: MedalRarity.RARE,
    category: MedalCategory.EXPLORATION,
    unlock_condition: 'exploration_percent >= 50',
    xp_reward: 350,
  },
  {
    key: MedalKey.CONQUISTADOR,
    name: 'Conquistador',
    description: 'Explore 100% of the city',
    rarity: MedalRarity.LEGENDARY,
    category: MedalCategory.EXPLORATION,
    unlock_condition: 'exploration_percent >= 100',
    xp_reward: 500,
  },
  {
    key: MedalKey.FIRST_FINDER,
    name: 'First Finder',
    description: 'Claim your first treasure',
    rarity: MedalRarity.COMMON,
    category: MedalCategory.TREASURE,
    unlock_condition: 'treasures_claimed >= 1',
    xp_reward: 50,
  },
  {
    key: MedalKey.TREASURE_SEEKER_10,
    name: 'Treasure Seeker',
    description: 'Claim 10 treasures',
    rarity: MedalRarity.UNCOMMON,
    category: MedalCategory.TREASURE,
    unlock_condition: 'treasures_claimed >= 10',
    xp_reward: 150,
  },
  {
    key: MedalKey.TREASURE_SEEKER_50,
    name: 'Treasure Hunter',
    description: 'Claim 50 treasures',
    rarity: MedalRarity.RARE,
    category: MedalCategory.TREASURE,
    unlock_condition: 'treasures_claimed >= 50',
    xp_reward: 300,
  },
  {
    key: MedalKey.TREASURE_SEEKER_100,
    name: 'Master Treasure Hunter',
    description: 'Claim 100 treasures',
    rarity: MedalRarity.EPIC,
    category: MedalCategory.TREASURE,
    unlock_condition: 'treasures_claimed >= 100',
    xp_reward: 400,
  },
  {
    key: MedalKey.RARE_HUNTER_5,
    name: 'Rare Hunter',
    description: 'Claim 5 RARE or better treasures',
    rarity: MedalRarity.RARE,
    category: MedalCategory.TREASURE,
    unlock_condition: 'rare_treasures_claimed >= 5',
    xp_reward: 250,
  },
  {
    key: MedalKey.RARE_HUNTER_20,
    name: 'Legendary Hunter',
    description: 'Claim 20 RARE or better treasures',
    rarity: MedalRarity.EPIC,
    category: MedalCategory.TREASURE,
    unlock_condition: 'rare_treasures_claimed >= 20',
    xp_reward: 400,
  },
  {
    key: MedalKey.VERIFIER_10,
    name: 'Verifier',
    description: 'Vote on 10 landmarks',
    rarity: MedalRarity.COMMON,
    category: MedalCategory.SOCIAL,
    unlock_condition: 'votes_cast >= 10',
    xp_reward: 75,
  },
  {
    key: MedalKey.VERIFIER_50,
    name: 'Community Pillar',
    description: 'Vote on 50 landmarks',
    rarity: MedalRarity.UNCOMMON,
    category: MedalCategory.SOCIAL,
    unlock_condition: 'votes_cast >= 50',
    xp_reward: 150,
  },
  {
    key: MedalKey.CARTOGRAPHER_1,
    name: 'Cartographer',
    description: 'Get 1 landmark approved',
    rarity: MedalRarity.UNCOMMON,
    category: MedalCategory.SOCIAL,
    unlock_condition: 'approved_landmarks >= 1',
    xp_reward: 200,
  },
  {
    key: MedalKey.CARTOGRAPHER_5,
    name: 'Master Cartographer',
    description: 'Get 5 landmarks approved',
    rarity: MedalRarity.RARE,
    category: MedalCategory.SOCIAL,
    unlock_condition: 'approved_landmarks >= 5',
    xp_reward: 350,
  },
  {
    key: MedalKey.CARTOGRAPHER_20,
    name: 'Guardian of the Map',
    description: 'Get 20 landmarks approved',
    rarity: MedalRarity.LEGENDARY,
    category: MedalCategory.SOCIAL,
    unlock_condition: 'approved_landmarks >= 20',
    xp_reward: 500,
  },
  {
    key: MedalKey.MASTER_OF_MADRID,
    name: 'Master of Madrid',
    description: 'Explore 50%, claim 50 treasures, and approve 5 landmarks',
    rarity: MedalRarity.LEGENDARY,
    category: MedalCategory.SPECIAL,
    unlock_condition:
      'exploration_percent >= 50 AND treasures_claimed >= 50 AND approved_landmarks >= 5',
    xp_reward: 500,
  },
];

@Injectable()
export class MedalsService implements OnModuleInit {
  private readonly logger = new Logger(MedalsService.name);

  constructor(
    @InjectRepository(MedalEntity)
    private medalRepository: Repository<MedalEntity>,
    @InjectRepository(UserMedalEntity)
    private userMedalRepository: Repository<UserMedalEntity>,
    @InjectRepository(TreasureClaimEntity)
    private claimRepository: Repository<TreasureClaimEntity>,
    @InjectRepository(LandmarkVoteEntity)
    private landmarkVoteRepository: Repository<LandmarkVoteEntity>,
    @InjectRepository(LandmarkEntity)
    private landmarkRepository: Repository<LandmarkEntity>,
    private usersService: UsersService,
  ) {}

  async onModuleInit(): Promise<void> {
    await this.seedMedals();
  }

  async getUserMedals(userId: string): Promise<MedalDto[]> {
    const [allMedals, userMedals] = await Promise.all([
      this.medalRepository.find({ order: { category: 'ASC', rarity: 'ASC' } }),
      this.userMedalRepository.find({
        where: { user_id: userId },
        relations: ['medal'],
      }),
    ]);

    const unlockedMap = new Map(
      userMedals.map(um => [um.medal_id, um.unlocked_at]),
    );

    return allMedals.map(medal => ({
      id: medal.id,
      key: medal.key,
      name: medal.name,
      description: medal.description,
      icon_url: medal.icon_url,
      rarity: medal.rarity,
      category: medal.category,
      unlock_condition: medal.unlock_condition,
      xp_reward: medal.xp_reward,
      unlocked: unlockedMap.has(medal.id),
      unlocked_at: unlockedMap.get(medal.id) ?? null,
    }));
  }

  async getUnlockedMedals(userId: string): Promise<MedalDto[]> {
    const medals = await this.getUserMedals(userId);
    return medals.filter(m => m.unlocked);
  }

  async checkAndAwardMedals(userId: string): Promise<void> {
    const user = await this.usersService.findById(userId);
    if (!user) return;

    const [
      allMedals,
      userMedals,
      claimCount,
      rareClaimCount,
      voteCount,
      approvedCount,
    ] = await Promise.all([
      this.medalRepository.find(),
      this.userMedalRepository.find({ where: { user_id: userId } }),
      this.claimRepository.count({ where: { user_id: userId } }),
      this.claimRepository
        .createQueryBuilder('tc')
        .innerJoin('tc.treasure', 't')
        .where('tc.user_id = :userId', { userId })
        .andWhere('t.rarity IN (:...rarities)', {
          rarities: RARE_OR_BETTER,
        })
        .getCount(),
      this.landmarkVoteRepository.count({ where: { user_id: userId } }),
      this.landmarkRepository.count({
        where: { creator_id: userId, status: LandmarkStatus.APPROVED },
      }),
    ]);

    const unlockedIds = new Set(userMedals.map(um => um.medal_id));
    const explorationPercent = Number(user.exploration_percent);

    const stats = {
      exploration_percent: explorationPercent,
      treasures_claimed: claimCount,
      rare_treasures_claimed: rareClaimCount,
      votes_cast: voteCount,
      approved_landmarks: approvedCount,
    };

    for (const medal of allMedals) {
      if (unlockedIds.has(medal.id)) continue;
      if (this.meetsCondition(medal.key, stats)) {
        await this.awardMedal(userId, medal);
      }
    }
  }

  private meetsCondition(
    key: MedalKey,
    stats: {
      exploration_percent: number;
      treasures_claimed: number;
      rare_treasures_claimed: number;
      votes_cast: number;
      approved_landmarks: number;
    },
  ): boolean {
    switch (key) {
      case MedalKey.FIRST_STEPS:
        return stats.exploration_percent >= 0.5;
      case MedalKey.EXPLORER_10:
        return stats.exploration_percent >= 10;
      case MedalKey.EXPLORER_25:
        return stats.exploration_percent >= 25;
      case MedalKey.EXPLORER_50:
        return stats.exploration_percent >= 50;
      case MedalKey.CONQUISTADOR:
        return stats.exploration_percent >= 100;
      case MedalKey.FIRST_FINDER:
        return stats.treasures_claimed >= 1;
      case MedalKey.TREASURE_SEEKER_10:
        return stats.treasures_claimed >= 10;
      case MedalKey.TREASURE_SEEKER_50:
        return stats.treasures_claimed >= 50;
      case MedalKey.TREASURE_SEEKER_100:
        return stats.treasures_claimed >= 100;
      case MedalKey.RARE_HUNTER_5:
        return stats.rare_treasures_claimed >= 5;
      case MedalKey.RARE_HUNTER_20:
        return stats.rare_treasures_claimed >= 20;
      case MedalKey.VERIFIER_10:
        return stats.votes_cast >= 10;
      case MedalKey.VERIFIER_50:
        return stats.votes_cast >= 50;
      case MedalKey.CARTOGRAPHER_1:
        return stats.approved_landmarks >= 1;
      case MedalKey.CARTOGRAPHER_5:
        return stats.approved_landmarks >= 5;
      case MedalKey.CARTOGRAPHER_20:
        return stats.approved_landmarks >= 20;
      case MedalKey.MASTER_OF_MADRID:
        return (
          stats.exploration_percent >= 50 &&
          stats.treasures_claimed >= 50 &&
          stats.approved_landmarks >= 5
        );
      default:
        return false;
    }
  }

  private async awardMedal(userId: string, medal: MedalEntity): Promise<void> {
    try {
      const userMedal = this.userMedalRepository.create({
        user_id: userId,
        medal_id: medal.id,
      });
      await this.userMedalRepository.save(userMedal);
      await this.usersService.incrementMedalsCount(userId);
      await this.usersService.addXp(userId, medal.xp_reward);
      this.logger.log(`Medal "${medal.name}" awarded to user ${userId}`);
    } catch {
      // Medal already unlocked (unique constraint) — ignore
    }
  }

  private async seedMedals(): Promise<void> {
    for (const seed of MEDAL_SEED) {
      const existing = await this.medalRepository.findOne({
        where: { key: seed.key },
      });
      if (!existing) {
        await this.medalRepository.save(this.medalRepository.create(seed));
      }
    }
    this.logger.log('Medal seeds verified');
  }
}
