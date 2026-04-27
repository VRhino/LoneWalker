import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BadRequestException, ConflictException } from '@nestjs/common';
import { LandmarksService } from './landmarks.service';
import {
  LandmarkEntity,
  LandmarkCategory,
  LandmarkStatus,
} from './entities/landmark.entity';
import { LandmarkVoteEntity } from './entities/landmark-vote.entity';
import { UsersService } from '../users/users.service';
import { MedalsService } from '../medals/medals.service';
import {
  makeLandmark,
  mockQueryBuilder,
} from '../../common/test/test-factories';

describe('LandmarksService', () => {
  let service: LandmarksService;

  const mockLandmarkRepo = {
    find: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockVoteRepo = {
    find: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockUsersService = {
    addCartographerPoints: jest.fn().mockResolvedValue(undefined),
  };

  const mockMedalsService = {
    checkAndAwardMedals: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LandmarksService,
        {
          provide: getRepositoryToken(LandmarkEntity),
          useValue: mockLandmarkRepo,
        },
        {
          provide: getRepositoryToken(LandmarkVoteEntity),
          useValue: mockVoteRepo,
        },
        { provide: UsersService, useValue: mockUsersService },
        { provide: MedalsService, useValue: mockMedalsService },
      ],
    }).compile();

    service = module.get<LandmarksService>(LandmarksService);
    jest.clearAllMocks();
    mockUsersService.addCartographerPoints.mockResolvedValue(undefined);
    mockMedalsService.checkAndAwardMedals.mockResolvedValue(undefined);
  });

  describe('proposeLandmark', () => {
    // Landmark at (40.4168, -3.7038)
    // User ~55m away (> 50m threshold)
    const landmarkLat = 40.4168;
    const landmarkLng = -3.7038;

    it('throws BadRequestException when user is more than 50m from landmark', async () => {
      await expect(
        service.proposeLandmark('user-1', {
          user_latitude: 40.4163, // ~55m south
          user_longitude: -3.7038,
          latitude: landmarkLat,
          longitude: landmarkLng,
          title: 'Test',
          description: 'Desc',
          category: LandmarkCategory.MONUMENT,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('saves landmark and awards cartographer points when within 50m', async () => {
      const landmark = makeLandmark();
      mockLandmarkRepo.create.mockReturnValue(landmark);
      mockLandmarkRepo.save.mockResolvedValue(landmark);

      const result = await service.proposeLandmark('user-1', {
        user_latitude: landmarkLat, // exactly on the landmark
        user_longitude: landmarkLng,
        latitude: landmarkLat,
        longitude: landmarkLng,
        title: 'My Landmark',
        description: 'A nice landmark',
        category: LandmarkCategory.MONUMENT,
      });

      expect(mockLandmarkRepo.save).toHaveBeenCalled();
      expect(mockUsersService.addCartographerPoints).toHaveBeenCalledWith(
        'user-1',
        10,
      );
      expect(result).toHaveProperty('id');
    });
  });

  describe('voteLandmark', () => {
    const voterId = 'voter-id';
    const landmarkId = 'landmark-id-1';

    it('throws BadRequestException when voter tries to vote on own landmark', async () => {
      const landmark = makeLandmark({ creator_id: voterId });
      mockLandmarkRepo.findOne.mockResolvedValue(landmark);

      await expect(
        service.voteLandmark(voterId, landmarkId, {
          vote: 1,
          comment: 'This is a mandatory comment',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws ConflictException when user already voted', async () => {
      const landmark = makeLandmark({ creator_id: 'creator-id' });
      mockLandmarkRepo.findOne.mockResolvedValue(landmark);
      mockVoteRepo.findOne.mockResolvedValue({ id: 'existing-vote' });

      await expect(
        service.voteLandmark(voterId, landmarkId, {
          vote: 1,
          comment: 'Mandatory comment here',
        }),
      ).rejects.toThrow(ConflictException);
    });

    it('approves landmark when net votes reach the threshold of 20', async () => {
      const landmark = makeLandmark({
        creator_id: 'creator-id',
        votes_positive: 19,
        votes_negative: 0,
      });
      // findOne is called multiple times: once in voteLandmark, once in getLandmarkById
      mockLandmarkRepo.findOne.mockResolvedValue(landmark);
      mockVoteRepo.findOne.mockResolvedValue(null);
      mockVoteRepo.create.mockReturnValue({ id: 'new-vote', vote: 1 });
      mockVoteRepo.save.mockResolvedValue({ id: 'new-vote' });
      mockVoteRepo.find.mockResolvedValue([]);
      mockLandmarkRepo.save.mockImplementation(async (l: LandmarkEntity) => l);

      await service.voteLandmark(voterId, landmarkId, {
        vote: 1,
        comment: 'This is a valid vote comment',
      });

      const saveCalls = mockLandmarkRepo.save.mock.calls as [LandmarkEntity][];
      const savedWithApproved = saveCalls.some(
        ([arg]) => arg.status === LandmarkStatus.APPROVED,
      );
      expect(savedWithApproved).toBe(true);
    });
  });

  describe('getApprovedLandmarks', () => {
    it('queries only APPROVED status landmarks via query builder', async () => {
      const qb = mockQueryBuilder([]);
      mockLandmarkRepo.createQueryBuilder.mockReturnValue(qb);

      await service.getApprovedLandmarks(40.4168, -3.7038);

      expect(qb.where).toHaveBeenCalledWith(
        'l.status = :status',
        expect.objectContaining({ status: LandmarkStatus.APPROVED }),
      );
    });
  });
});
