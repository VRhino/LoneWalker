import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { RankingEntity } from './ranking.entity';
import { UserEntity } from '../users/entities/user.entity';
import { TreasureClaimEntity } from '../treasures/entities/treasure-claim.entity';
import { PrivacyMode } from '../../common/enums/privacy-mode.enum';
import {
  RankingEntryDto,
  RankingListDto,
  UserPositionDto,
} from './dto/ranking-response.dto';
import { CacheService } from '../../cache/cache.service';

const RANKING_TTL = 3600; // 1 hour — matches cron recalculation interval
const USER_POSITION_TTL = 600; // 10 min — changes more often than full ranking

@Injectable()
export class RankingService {
  private readonly logger = new Logger(RankingService.name);

  constructor(
    @InjectRepository(RankingEntity)
    private rankingRepository: Repository<RankingEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(TreasureClaimEntity)
    private claimRepository: Repository<TreasureClaimEntity>,
    private dataSource: DataSource,
    private cache: CacheService,
  ) {}

  @Cron(CronExpression.EVERY_HOUR)
  async calculateAndUpdateRankings(): Promise<void> {
    this.logger.log('Recalculating rankings...');

    const users = await this.userRepository.find({
      where: { is_active: true },
      select: ['id', 'exploration_percent', 'total_xp', 'medals_count'],
    });

    const claimCounts = await this.claimRepository
      .createQueryBuilder('tc')
      .select('tc.user_id', 'user_id')
      .addSelect('COUNT(*)', 'count')
      .groupBy('tc.user_id')
      .getRawMany<{ user_id: string; count: string }>();

    const claimMap = new Map<string, number>(
      claimCounts.map(r => [r.user_id, parseInt(r.count, 10)]),
    );

    const scored = users.map(u => ({
      user_id: u.id,
      exploration_percent: Number(u.exploration_percent),
      treasures_found: claimMap.get(u.id) ?? 0,
      xp_total: u.total_xp,
      medals_count: u.medals_count,
      score: this.computeScore(
        Number(u.exploration_percent),
        claimMap.get(u.id) ?? 0,
        u.total_xp,
        u.medals_count,
      ),
    }));

    scored.sort((a, b) => b.score - a.score);

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      for (let i = 0; i < scored.length; i++) {
        const s = scored[i];
        await queryRunner.manager
          .createQueryBuilder()
          .insert()
          .into(RankingEntity)
          .values({
            user_id: s.user_id,
            rank: i + 1,
            exploration_percent: s.exploration_percent,
            treasures_found: s.treasures_found,
            xp_total: s.xp_total,
            medals_count: s.medals_count,
            score: s.score,
          })
          .orUpdate(
            [
              'rank',
              'exploration_percent',
              'treasures_found',
              'xp_total',
              'medals_count',
              'score',
              'updated_at',
            ],
            ['user_id'],
          )
          .execute();
      }
      await queryRunner.commitTransaction();
      this.logger.log(`Rankings updated for ${scored.length} users`);
      await this.cache.delPattern('ranking:*');
    } catch (err) {
      await queryRunner.rollbackTransaction();
      this.logger.error('Failed to update rankings', err);
    } finally {
      await queryRunner.release();
    }
  }

  async getGlobalRanking(
    currentUserId: string,
    page: number = 1,
    limit: number = 50,
  ): Promise<RankingListDto> {
    const cacheKey = `ranking:global:${page}:${limit}`;
    const cached = await this.cache.get<{
      entries: RankingEntryDto[];
      total: number;
    }>(cacheKey);

    if (cached) {
      return {
        ...cached,
        page,
        limit,
        entries: cached.entries.map(e => ({
          ...e,
          is_current_user: e.user_id === currentUserId,
        })),
      };
    }

    const offset = (page - 1) * limit;

    const [entries, total] = await this.rankingRepository
      .createQueryBuilder('r')
      .innerJoinAndSelect('r.user', 'u')
      .where('u.privacy_mode = :mode', { mode: PrivacyMode.PUBLIC })
      .andWhere('u.is_active = true')
      .orderBy('r.rank', 'ASC')
      .skip(offset)
      .take(limit)
      .getManyAndCount();

    const dtos = entries.map(e => this.toDto(e, ''));
    await this.cache.set(cacheKey, { entries: dtos, total }, RANKING_TTL);

    return {
      entries: dtos.map(e => ({
        ...e,
        is_current_user: e.user_id === currentUserId,
      })),
      total,
      page,
      limit,
    };
  }

  async getWeeklyRanking(
    currentUserId: string,
    page: number = 1,
    limit: number = 50,
  ): Promise<RankingListDto> {
    const cacheKey = `ranking:weekly:${page}:${limit}`;
    const cached = await this.cache.get<{
      entries: RankingEntryDto[];
      total: number;
    }>(cacheKey);

    if (cached) {
      return {
        ...cached,
        page,
        limit,
        entries: cached.entries.map(e => ({
          ...e,
          is_current_user: e.user_id === currentUserId,
        })),
      };
    }

    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const [entries, total] = await this.rankingRepository
      .createQueryBuilder('r')
      .innerJoinAndSelect('r.user', 'u')
      .where('u.privacy_mode = :mode', { mode: PrivacyMode.PUBLIC })
      .andWhere('u.is_active = true')
      .andWhere('r.updated_at >= :weekAgo', { weekAgo })
      .orderBy('r.score', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    const dtos = entries.map(e => this.toDto(e, ''));
    await this.cache.set(cacheKey, { entries: dtos, total }, RANKING_TTL);

    return {
      entries: dtos.map(e => ({
        ...e,
        is_current_user: e.user_id === currentUserId,
      })),
      total,
      page,
      limit,
    };
  }

  async getDistrictRanking(
    _districtId: string,
    currentUserId: string,
  ): Promise<RankingListDto> {
    // District filtering will be implemented when district spatial data is added
    return this.getGlobalRanking(currentUserId);
  }

  async getUserPosition(userId: string): Promise<UserPositionDto> {
    const cacheKey = `ranking:user:${userId}`;
    const cached = await this.cache.get<UserPositionDto>(cacheKey);
    if (cached) return cached;

    const total = await this.rankingRepository.count();

    const entry = await this.rankingRepository.findOne({
      where: { user_id: userId },
    });

    let result: UserPositionDto;

    if (!entry) {
      const user = await this.userRepository.findOne({
        where: { id: userId },
        select: ['exploration_percent', 'total_xp', 'medals_count'],
      });
      const treasuresFound = await this.claimRepository.count({
        where: { user_id: userId },
      });

      result = {
        rank: total + 1,
        score: 0,
        total_players: total,
        exploration_percent: Number(user?.exploration_percent ?? 0),
        treasures_found: treasuresFound,
        xp_total: user?.total_xp ?? 0,
        medals_count: user?.medals_count ?? 0,
      };
    } else {
      result = {
        rank: entry.rank,
        score: Number(entry.score),
        total_players: total,
        exploration_percent: Number(entry.exploration_percent),
        treasures_found: entry.treasures_found,
        xp_total: entry.xp_total,
        medals_count: entry.medals_count,
      };
    }

    await this.cache.set(cacheKey, result, USER_POSITION_TTL);
    return result;
  }

  private computeScore(
    explorationPercent: number,
    treasuresFound: number,
    xpTotal: number,
    medalsCount: number,
  ): number {
    return (
      explorationPercent * 0.4 +
      treasuresFound * 0.3 +
      (xpTotal / 1000) * 0.2 +
      medalsCount * 0.1
    );
  }

  private toDto(entry: RankingEntity, currentUserId: string): RankingEntryDto {
    return {
      rank: entry.rank,
      user_id: entry.user_id,
      username: entry.user.username,
      avatar_url: entry.user.avatar_url ?? null,
      exploration_percent: Number(entry.exploration_percent),
      treasures_found: entry.treasures_found,
      xp_total: entry.xp_total,
      medals_count: entry.medals_count,
      score: Number(entry.score),
      is_current_user: entry.user_id === currentUserId,
      updated_at: entry.updated_at,
    };
  }
}
