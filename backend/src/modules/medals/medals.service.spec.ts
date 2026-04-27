import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { MedalsService } from './medals.service';
import { MedalEntity, MedalKey, MedalRarity, MedalCategory } from './entities/medal.entity';
import { UserMedalEntity } from './entities/user-medal.entity';
import { TreasureClaimEntity } from '../treasures/entities/treasure-claim.entity';
import { LandmarkVoteEntity } from '../landmarks/entities/landmark-vote.entity';
import { LandmarkEntity } from '../landmarks/entities/landmark.entity';
import { UsersService } from '../users/users.service';
import { makeUser, makeMedal, mockQueryBuilder } from '../../common/test/test-factories';

describe('MedalsService', () => {
  let service: MedalsService;

  const mockMedalRepo = {
    find: jest.fn(),
    findOne: jest.fn().mockResolvedValue({ id: 'medal-1' }), // prevent seedMedals from saving
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockUserMedalRepo = {
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockClaimRepo = {
    count: jest.fn().mockResolvedValue(0),
    createQueryBuilder: jest.fn(),
  };

  const mockVoteRepo = {
    count: jest.fn().mockResolvedValue(0),
  };

  const mockLandmarkRepo = {
    count: jest.fn().mockResolvedValue(0),
  };

  const mockUsersService = {
    findById: jest.fn(),
    addXp: jest.fn().mockResolvedValue(undefined),
    incrementMedalsCount: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MedalsService,
        { provide: getRepositoryToken(MedalEntity), useValue: mockMedalRepo },
        { provide: getRepositoryToken(UserMedalEntity), useValue: mockUserMedalRepo },
        { provide: getRepositoryToken(TreasureClaimEntity), useValue: mockClaimRepo },
        { provide: getRepositoryToken(LandmarkVoteEntity), useValue: mockVoteRepo },
        { provide: getRepositoryToken(LandmarkEntity), useValue: mockLandmarkRepo },
        { provide: UsersService, useValue: mockUsersService },
      ],
    }).compile();

    service = module.get<MedalsService>(MedalsService);
    jest.clearAllMocks();

    // Prevent seedMedals from writing during tests
    mockMedalRepo.findOne.mockResolvedValue({ id: 'medal-1' });
    mockClaimRepo.count.mockResolvedValue(0);
    mockVoteRepo.count.mockResolvedValue(0);
    mockLandmarkRepo.count.mockResolvedValue(0);
    mockUsersService.addXp.mockResolvedValue(undefined);
    mockUsersService.incrementMedalsCount.mockResolvedValue(undefined);

    // Set up rare claim count query builder
    const rareQb = mockQueryBuilder([]);
    rareQb.getCount.mockResolvedValue(0);
    mockClaimRepo.createQueryBuilder.mockReturnValue(rareQb);
  });

  describe('checkAndAwardMedals', () => {
    it('does nothing when user is not found', async () => {
      mockUsersService.findById.mockResolvedValue(null);

      await service.checkAndAwardMedals('nonexistent-user');

      expect(mockUserMedalRepo.save).not.toHaveBeenCalled();
    });

    it('awards FIRST_STEPS medal when exploration_percent >= 0.5', async () => {
      const user = makeUser({ exploration_percent: 0.5 });
      mockUsersService.findById.mockResolvedValue(user);

      const firstStepsMedal = makeMedal({ id: 'medal-first-steps', key: MedalKey.FIRST_STEPS });
      mockMedalRepo.find.mockResolvedValue([firstStepsMedal]);
      mockUserMedalRepo.find.mockResolvedValue([]); // no medals yet
      mockUserMedalRepo.create.mockReturnValue({ id: 'um-1' });
      mockUserMedalRepo.save.mockResolvedValue({ id: 'um-1' });

      await service.checkAndAwardMedals('user-1');

      expect(mockUserMedalRepo.save).toHaveBeenCalled();
    });

    it('does not award medals that are already unlocked', async () => {
      const user = makeUser({ exploration_percent: 1 });
      mockUsersService.findById.mockResolvedValue(user);

      const firstStepsMedal = makeMedal({ id: 'medal-first-steps', key: MedalKey.FIRST_STEPS });
      mockMedalRepo.find.mockResolvedValue([firstStepsMedal]);
      // Medal already unlocked
      mockUserMedalRepo.find.mockResolvedValue([
        { medal_id: 'medal-first-steps', user_id: 'user-1' },
      ]);

      await service.checkAndAwardMedals('user-1');

      expect(mockUserMedalRepo.save).not.toHaveBeenCalled();
    });
  });

  describe('getUserMedals', () => {
    const commonMedal = makeMedal({ id: 'medal-1', key: MedalKey.FIRST_STEPS });

    it('returns medals with unlocked=true for earned medals', async () => {
      mockMedalRepo.find.mockResolvedValue([commonMedal]);
      mockUserMedalRepo.find.mockResolvedValue([
        { medal_id: 'medal-1', user_id: 'user-1', unlocked_at: new Date() },
      ]);

      const result = await service.getUserMedals('user-1');

      expect(result[0].unlocked).toBe(true);
      expect(result[0].key).toBe(MedalKey.FIRST_STEPS);
    });

    it('returns medals with unlocked=false for unearned medals', async () => {
      mockMedalRepo.find.mockResolvedValue([commonMedal]);
      mockUserMedalRepo.find.mockResolvedValue([]); // none earned

      const result = await service.getUserMedals('user-1');

      expect(result[0].unlocked).toBe(false);
      expect(result[0].unlocked_at).toBeNull();
    });
  });
});
