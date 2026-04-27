import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { TreasuresService } from './treasures.service';
import { TreasureEntity, TreasureRarity } from './entities/treasure.entity';
import { TreasureClaimEntity } from './entities/treasure-claim.entity';
import { UsersService } from '../users/users.service';
import { MedalsService } from '../medals/medals.service';
import {
  makeTreasure,
  mockQueryBuilder,
} from '../../common/test/test-factories';

describe('TreasuresService', () => {
  let service: TreasuresService;

  const mockTreasureRepo = {
    findOneBy: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockClaimRepo = {
    findOneBy: jest.fn(),
    findBy: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    count: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockUsersService = {
    addXp: jest.fn().mockResolvedValue(undefined),
  };

  const mockMedalsService = {
    checkAndAwardMedals: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TreasuresService,
        {
          provide: getRepositoryToken(TreasureEntity),
          useValue: mockTreasureRepo,
        },
        {
          provide: getRepositoryToken(TreasureClaimEntity),
          useValue: mockClaimRepo,
        },
        { provide: UsersService, useValue: mockUsersService },
        { provide: MedalsService, useValue: mockMedalsService },
      ],
    }).compile();

    service = module.get<TreasuresService>(TreasuresService);
    jest.clearAllMocks();
    mockUsersService.addXp.mockResolvedValue(undefined);
    mockMedalsService.checkAndAwardMedals.mockResolvedValue(undefined);
  });

  describe('claimTreasure', () => {
    // Treasure at (40.4168, -3.7038)
    // User far away: ~22m north
    const treasureLat = 40.4168;
    const treasureLng = -3.7038;
    const userFarLat = 40.417;
    const userFarLng = -3.7038;
    // User close: ~1.5m offset
    const userCloseLat = 40.41681;
    const userCloseLng = -3.70381;

    it('throws NotFoundException when treasure does not exist', async () => {
      mockTreasureRepo.findOneBy.mockResolvedValue(null);

      await expect(
        service.claimTreasure(
          'user-1',
          'treasure-1',
          treasureLat,
          treasureLng,
          5,
        ),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws BadRequestException when user is more than 10m away', async () => {
      const treasure = makeTreasure({
        latitude: treasureLat,
        longitude: treasureLng,
      });
      mockTreasureRepo.findOneBy.mockResolvedValue(treasure);

      await expect(
        service.claimTreasure(
          'user-1',
          'treasure-1',
          userFarLat,
          userFarLng,
          5,
        ),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws BadRequestException when GPS accuracy exceeds 50m', async () => {
      const treasure = makeTreasure({
        latitude: treasureLat,
        longitude: treasureLng,
      });
      mockTreasureRepo.findOneBy.mockResolvedValue(treasure);

      await expect(
        service.claimTreasure(
          'user-1',
          'treasure-1',
          userCloseLat,
          userCloseLng,
          51,
        ),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws BadRequestException when user already claimed this treasure', async () => {
      const treasure = makeTreasure({
        latitude: treasureLat,
        longitude: treasureLng,
      });
      mockTreasureRepo.findOneBy.mockResolvedValue(treasure);
      mockClaimRepo.findOneBy.mockResolvedValue({ id: 'claim-existing' });

      await expect(
        service.claimTreasure(
          'user-1',
          'treasure-1',
          userCloseLat,
          userCloseLng,
          5,
        ),
      ).rejects.toThrow(BadRequestException);
    });

    it('saves claim and awards XP on valid claim', async () => {
      const treasure = makeTreasure({
        latitude: treasureLat,
        longitude: treasureLng,
        rarity: TreasureRarity.RARE,
      });
      mockTreasureRepo.findOneBy.mockResolvedValue(treasure);
      mockClaimRepo.findOneBy.mockResolvedValue(null);
      mockClaimRepo.create.mockReturnValue({ id: 'new-claim' });
      mockClaimRepo.save.mockResolvedValue({ id: 'new-claim' });
      mockTreasureRepo.save.mockResolvedValue(treasure);

      const result = await service.claimTreasure(
        'user-1',
        'treasure-1',
        userCloseLat,
        userCloseLng,
        5,
      );

      expect(mockClaimRepo.save).toHaveBeenCalled();
      expect(mockUsersService.addXp).toHaveBeenCalled();
      expect(result.claimed).toBe(true);
      expect(result.xpEarned).toBeGreaterThan(0);
    });
  });

  describe('getTreasureClaimsStats', () => {
    it('aggregates claims by rarity and returns totals', async () => {
      const qb = mockQueryBuilder([
        { treasure: { rarity: TreasureRarity.COMMON }, xp_earned: 50 },
        { treasure: { rarity: TreasureRarity.RARE }, xp_earned: 125 },
      ]);
      mockClaimRepo.createQueryBuilder.mockReturnValue(qb);

      const result = await service.getTreasureClaimsStats('user-1');

      expect(result.total_claimed).toBe(2);
      expect(result.total_xp).toBe(175);
      expect(result.by_rarity[TreasureRarity.COMMON]).toBe(1);
      expect(result.by_rarity[TreasureRarity.RARE]).toBe(1);
      expect(result.by_rarity[TreasureRarity.EPIC]).toBe(0);
    });
  });
});
