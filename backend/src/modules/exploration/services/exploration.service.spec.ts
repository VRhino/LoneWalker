import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BadRequestException } from '@nestjs/common';
import { ExplorationService } from './exploration.service';
import { ExplorationEntity } from '../entities/exploration.entity';
import { UsersService } from '../../users/users.service';
import { MedalsService } from '../../medals/medals.service';
import { makeUser } from '../../../common/test/test-factories';

describe('ExplorationService', () => {
  let service: ExplorationService;

  const mockExplorationRepo = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    findAndCount: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockUsersService = {
    findByIdOrThrow: jest.fn(),
    findById: jest.fn(),
    updateExplorationStats: jest.fn().mockResolvedValue(undefined),
  };

  const mockMedalsService = {
    checkAndAwardMedals: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ExplorationService,
        { provide: getRepositoryToken(ExplorationEntity), useValue: mockExplorationRepo },
        { provide: UsersService, useValue: mockUsersService },
        { provide: MedalsService, useValue: mockMedalsService },
      ],
    }).compile();

    service = module.get<ExplorationService>(ExplorationService);
    jest.clearAllMocks();
    mockUsersService.updateExplorationStats.mockResolvedValue(undefined);
    mockMedalsService.checkAndAwardMedals.mockResolvedValue(undefined);
  });

  describe('registerExploration', () => {
    const validDto = {
      latitude: 40.4168,
      longitude: -3.7038,
      speed_kmh: 5,
      accuracy_meters: 10,
    };

    it('throws BadRequestException when speed exceeds 20 km/h', async () => {
      await expect(
        service.registerExploration('user-1', { ...validDto, speed_kmh: 25 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws BadRequestException when GPS accuracy exceeds 50m', async () => {
      await expect(
        service.registerExploration('user-1', { ...validDto, accuracy_meters: 51 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('saves exploration record and updates user stats on valid input', async () => {
      const user = makeUser({ exploration_percent: 10, total_xp: 100 });
      mockUsersService.findByIdOrThrow.mockResolvedValue(user);
      mockExplorationRepo.create.mockReturnValue({ user_id: 'user-1', ...validDto });
      mockExplorationRepo.save.mockResolvedValue({ id: 'exp-1' });

      const result = await service.registerExploration('user-1', validDto);

      expect(mockExplorationRepo.save).toHaveBeenCalled();
      expect(mockUsersService.updateExplorationStats).toHaveBeenCalled();
      expect(result).toHaveProperty('exploration_percent');
      expect(result.fog_updated).toBe(true);
    });

    it('caps exploration_percent at 100 when user is near the limit', async () => {
      const user = makeUser({ exploration_percent: 99.6, total_xp: 990 });
      mockUsersService.findByIdOrThrow.mockResolvedValue(user);
      mockExplorationRepo.create.mockReturnValue({});
      mockExplorationRepo.save.mockResolvedValue({ id: 'exp-2' });

      const result = await service.registerExploration('user-1', validDto);

      expect(result.exploration_percent).toBe(100);
    });
  });

  describe('getExplorationProgress', () => {
    it('returns ExplorationProgressDto with current user stats', async () => {
      const user = makeUser({ exploration_percent: 25, total_xp: 500 });
      mockUsersService.findByIdOrThrow.mockResolvedValue(user);

      const result = await service.getExplorationProgress('user-1');

      expect(result.user_id).toBe('user-1');
      expect(result.exploration_percent).toBe(25);
      expect(result.total_xp).toBe(500);
      expect(result.fog_updated).toBe(false);
    });
  });
});
