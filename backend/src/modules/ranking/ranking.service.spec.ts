import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { RankingService } from './ranking.service';
import { RankingEntity } from './ranking.entity';
import { UserEntity } from '../users/entities/user.entity';
import { TreasureClaimEntity } from '../treasures/entities/treasure-claim.entity';
import { PrivacyMode } from '../../common/enums/privacy-mode.enum';
import { makeUser, mockQueryBuilder } from '../../common/test/test-factories';

describe('RankingService', () => {
  let service: RankingService;

  const mockInsertQb = mockQueryBuilder([]);

  const mockQueryRunner = {
    connect: jest.fn().mockResolvedValue(undefined),
    startTransaction: jest.fn().mockResolvedValue(undefined),
    commitTransaction: jest.fn().mockResolvedValue(undefined),
    rollbackTransaction: jest.fn().mockResolvedValue(undefined),
    release: jest.fn().mockResolvedValue(undefined),
    manager: {
      createQueryBuilder: jest.fn().mockReturnValue(mockInsertQb),
    },
  };

  const mockDataSource = {
    createQueryRunner: jest.fn().mockReturnValue(mockQueryRunner),
  };

  const mockRankingRepo = {
    count: jest.fn(),
    findOne: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockUserRepo = {
    find: jest.fn(),
    findOne: jest.fn(),
  };

  const mockClaimRepo = {
    count: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RankingService,
        {
          provide: getRepositoryToken(RankingEntity),
          useValue: mockRankingRepo,
        },
        { provide: getRepositoryToken(UserEntity), useValue: mockUserRepo },
        {
          provide: getRepositoryToken(TreasureClaimEntity),
          useValue: mockClaimRepo,
        },
        { provide: DataSource, useValue: mockDataSource },
      ],
    }).compile();

    service = module.get<RankingService>(RankingService);
    jest.clearAllMocks();
    mockDataSource.createQueryRunner.mockReturnValue(mockQueryRunner);
    mockQueryRunner.connect.mockResolvedValue(undefined);
    mockQueryRunner.startTransaction.mockResolvedValue(undefined);
    mockQueryRunner.commitTransaction.mockResolvedValue(undefined);
    mockQueryRunner.release.mockResolvedValue(undefined);
    mockQueryRunner.manager.createQueryBuilder.mockReturnValue(mockInsertQb);
  });

  describe('calculateAndUpdateRankings', () => {
    it('computes score using weights 0.4 / 0.3 / 0.2 / 0.1', async () => {
      // exploration=40, treasures=5, xp=1000, medals=3
      // expected score = 40*0.4 + 5*0.3 + 1.0*0.2 + 3*0.1 = 16 + 1.5 + 0.2 + 0.3 = 18.0
      const user = makeUser({
        id: 'user-score',
        exploration_percent: 40,
        total_xp: 1000,
        medals_count: 3,
        is_active: true,
      });
      mockUserRepo.find.mockResolvedValue([user]);

      const claimQb = mockQueryBuilder([{ user_id: 'user-score', count: '5' }]);
      mockClaimRepo.createQueryBuilder.mockReturnValue(claimQb);

      await service.calculateAndUpdateRankings();

      expect(mockQueryRunner.commitTransaction).toHaveBeenCalled();
      expect(mockQueryRunner.manager.createQueryBuilder).toHaveBeenCalled();

      const valuesCalls = (mockInsertQb.values as jest.Mock).mock.calls;
      expect(valuesCalls.length).toBeGreaterThan(0);
      const savedEntry = valuesCalls[0][0];
      expect(savedEntry.score).toBeCloseTo(18.0, 1);
    });
  });

  describe('getGlobalRanking', () => {
    it('returns paginated RankingListDto with correct page and limit', async () => {
      const user = makeUser({ privacy_mode: PrivacyMode.PUBLIC });
      const rankingEntry = {
        rank: 1,
        user_id: user.id,
        user,
        score: 10,
        exploration_percent: 20,
        treasures_found: 3,
        xp_total: 100,
        medals_count: 1,
        updated_at: new Date(),
      };
      const qb = mockQueryBuilder([rankingEntry]);
      qb.getManyAndCount.mockResolvedValue([[rankingEntry], 1]);
      mockRankingRepo.createQueryBuilder.mockReturnValue(qb);

      const result = await service.getGlobalRanking('current-user', 2, 10);

      expect(result.page).toBe(2);
      expect(result.limit).toBe(10);
      expect(result.entries.length).toBe(1);
      expect(qb.skip).toHaveBeenCalledWith(10); // (page-1)*limit = 1*10 = 10
    });

    it('applies PUBLIC privacy filter to the query', async () => {
      const qb = mockQueryBuilder([]);
      qb.getManyAndCount.mockResolvedValue([[], 0]);
      mockRankingRepo.createQueryBuilder.mockReturnValue(qb);

      await service.getGlobalRanking('current-user');

      expect(qb.where).toHaveBeenCalledWith(
        'u.privacy_mode = :mode',
        expect.objectContaining({ mode: PrivacyMode.PUBLIC }),
      );
    });
  });

  describe('getUserPosition', () => {
    it('returns rank from ranking table when entry exists', async () => {
      mockRankingRepo.count.mockResolvedValue(10);
      mockRankingRepo.findOne.mockResolvedValue({
        rank: 3,
        score: 25.5,
        exploration_percent: 15,
        treasures_found: 5,
        xp_total: 200,
        medals_count: 2,
      });

      const result = await service.getUserPosition('user-1');

      expect(result.rank).toBe(3);
      expect(result.total_players).toBe(10);
    });

    it('returns total+1 as rank when user has no ranking entry', async () => {
      mockRankingRepo.count.mockResolvedValue(10);
      mockRankingRepo.findOne.mockResolvedValue(null);
      mockUserRepo.findOne.mockResolvedValue(
        makeUser({ exploration_percent: 0, total_xp: 0, medals_count: 0 }),
      );
      mockClaimRepo.count.mockResolvedValue(0);

      const result = await service.getUserPosition('new-user');

      expect(result.rank).toBe(11); // 10 + 1
      expect(result.score).toBe(0);
      expect(result.total_players).toBe(10);
    });
  });
});
