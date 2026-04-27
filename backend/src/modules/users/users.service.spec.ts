import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConflictException } from '@nestjs/common';
import { UsersService } from './users.service';
import { UserEntity } from './entities/user.entity';
import { makeUser } from '../../common/test/test-factories';

jest.mock('bcrypt', () => ({
  genSalt: jest.fn().mockResolvedValue('mock-salt'),
  hash: jest.fn().mockResolvedValue('$2b$10$mockhash'),
  compare: jest.fn(),
}));

import * as bcrypt from 'bcrypt';

describe('UsersService', () => {
  let service: UsersService;

  const mockRepo = {
    findOne: jest.fn(),
    findOneBy: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    update: jest.fn(),
    increment: jest.fn(),
    decrement: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(UserEntity), useValue: mockRepo },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    jest.clearAllMocks();
    (bcrypt.genSalt as jest.Mock).mockResolvedValue('mock-salt');
    (bcrypt.hash as jest.Mock).mockResolvedValue('$2b$10$mockhash');
  });

  describe('create', () => {
    it('throws ConflictException when email already exists', async () => {
      const existing = makeUser({ email: 'test@example.com' });
      mockRepo.findOne.mockResolvedValue(existing);

      await expect(
        service.create('newuser', 'test@example.com', 'password'),
      ).rejects.toThrow(ConflictException);
    });

    it('throws ConflictException when username already exists', async () => {
      const existing = makeUser({
        email: 'other@example.com',
        username: 'testuser',
      });
      mockRepo.findOne.mockResolvedValue(existing);

      await expect(
        service.create('testuser', 'new@example.com', 'password'),
      ).rejects.toThrow(ConflictException);
    });

    it('hashes password and saves user on valid input', async () => {
      mockRepo.findOne.mockResolvedValue(null);
      const newUser = makeUser({ id: 'new-id' });
      mockRepo.create.mockReturnValue(newUser);
      mockRepo.save.mockResolvedValue(newUser);

      const result = await service.create(
        'newuser',
        'new@example.com',
        'password123',
      );

      expect(bcrypt.hash).toHaveBeenCalled();
      expect(mockRepo.save).toHaveBeenCalled();
      expect(result).toEqual(newUser);
    });
  });

  describe('findByEmail', () => {
    it('returns user when found', async () => {
      const user = makeUser();
      mockRepo.findOne.mockResolvedValue(user);

      const result = await service.findByEmail('test@example.com');
      expect(result).toEqual(user);
    });

    it('returns null when user not found', async () => {
      mockRepo.findOne.mockResolvedValue(null);

      const result = await service.findByEmail('notfound@example.com');
      expect(result).toBeNull();
    });
  });

  describe('verifyPassword', () => {
    it('returns true for correct password', async () => {
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await service.verifyPassword('password', '$2b$10$hash');
      expect(result).toBe(true);
    });

    it('returns false for incorrect password', async () => {
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      const result = await service.verifyPassword('wrong', '$2b$10$hash');
      expect(result).toBe(false);
    });
  });

  describe('verifyRefreshToken', () => {
    it('returns false when user has no refresh_token_hash', async () => {
      const user = makeUser({ refresh_token_hash: null });
      mockRepo.findOne.mockResolvedValue(user);

      const result = await service.verifyRefreshToken('user-id', 'some-token');
      expect(result).toBe(false);
    });

    it('returns true when token matches hash', async () => {
      const user = makeUser({ refresh_token_hash: '$2b$10$refreshhash' });
      mockRepo.findOne.mockResolvedValue(user);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await service.verifyRefreshToken(
        'user-id',
        'valid-refresh-token',
      );
      expect(result).toBe(true);
    });
  });

  describe('addCartographerPoints', () => {
    it('calls increment for positive points', async () => {
      mockRepo.increment.mockResolvedValue(undefined);

      await service.addCartographerPoints('user-id', 10);
      expect(mockRepo.increment).toHaveBeenCalledWith(
        { id: 'user-id' },
        'cartographer_points',
        10,
      );
    });

    it('calls decrement for negative points', async () => {
      mockRepo.decrement.mockResolvedValue(undefined);

      await service.addCartographerPoints('user-id', -5);
      expect(mockRepo.decrement).toHaveBeenCalledWith(
        { id: 'user-id' },
        'cartographer_points',
        5,
      );
    });
  });
});
