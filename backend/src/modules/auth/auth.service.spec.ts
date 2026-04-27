import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { TokenService } from './services/token.service';
import { makeUser } from '../../common/test/test-factories';

describe('AuthService', () => {
  let service: AuthService;
  let usersService: jest.Mocked<Pick<UsersService, 'create' | 'findByEmail' | 'verifyPassword' | 'updateRefreshToken' | 'updateLastLogin' | 'verifyRefreshToken'>>;
  let tokenService: jest.Mocked<Pick<TokenService, 'generateTokens' | 'generateAccessToken' | 'verifyAndDecode'>>;

  const mockUsersService = {
    create: jest.fn(),
    findByEmail: jest.fn(),
    verifyPassword: jest.fn(),
    updateRefreshToken: jest.fn().mockResolvedValue(undefined),
    updateLastLogin: jest.fn().mockResolvedValue(undefined),
    verifyRefreshToken: jest.fn(),
  };

  const mockTokenService = {
    generateTokens: jest.fn().mockReturnValue({
      access_token: 'access.token',
      refresh_token: 'refresh.token',
    }),
    generateAccessToken: jest.fn().mockReturnValue('new.access.token'),
    verifyAndDecode: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn().mockReturnValue(900),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: mockUsersService },
        { provide: TokenService, useValue: mockTokenService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    usersService = module.get(UsersService);
    tokenService = module.get(TokenService);
    jest.clearAllMocks();
    mockUsersService.updateRefreshToken.mockResolvedValue(undefined);
    mockUsersService.updateLastLogin.mockResolvedValue(undefined);
    mockTokenService.generateTokens.mockReturnValue({
      access_token: 'access.token',
      refresh_token: 'refresh.token',
    });
    mockTokenService.generateAccessToken.mockReturnValue('new.access.token');
    mockConfigService.get.mockReturnValue(900);
  });

  describe('register', () => {
    it('throws BadRequestException when passwords do not match', async () => {
      await expect(
        service.register({
          username: 'user',
          email: 'test@example.com',
          password: 'pass1',
          passwordConfirm: 'pass2',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('creates user, generates tokens, and stores refresh token on success', async () => {
      const user = makeUser();
      mockUsersService.create.mockResolvedValue(user);

      await service.register({
        username: 'user',
        email: 'test@example.com',
        password: 'password',
        passwordConfirm: 'password',
      });

      expect(mockUsersService.create).toHaveBeenCalledWith('user', 'test@example.com', 'password');
      expect(mockTokenService.generateTokens).toHaveBeenCalledWith(user.id);
      expect(mockUsersService.updateRefreshToken).toHaveBeenCalledWith(user.id, 'refresh.token');
    });

    it('returns AuthResponseDto with user and tokens', async () => {
      const user = makeUser();
      mockUsersService.create.mockResolvedValue(user);

      const result = await service.register({
        username: 'user',
        email: 'test@example.com',
        password: 'password',
        passwordConfirm: 'password',
      });

      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('tokens');
      expect(result.tokens.access_token).toBe('access.token');
    });
  });

  describe('login', () => {
    it('throws UnauthorizedException when email is not found', async () => {
      mockUsersService.findByEmail.mockResolvedValue(null);

      await expect(
        service.login({ email: 'unknown@example.com', password: 'pass' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('throws UnauthorizedException when password is invalid', async () => {
      const user = makeUser();
      mockUsersService.findByEmail.mockResolvedValue(user);
      mockUsersService.verifyPassword.mockResolvedValue(false);

      await expect(
        service.login({ email: user.email, password: 'wrong' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('returns AuthResponseDto on valid credentials', async () => {
      const user = makeUser();
      mockUsersService.findByEmail.mockResolvedValue(user);
      mockUsersService.verifyPassword.mockResolvedValue(true);

      const result = await service.login({ email: user.email, password: 'correctpass' });

      expect(result).toHaveProperty('user');
      expect(result.tokens.access_token).toBe('access.token');
    });
  });

  describe('refreshToken', () => {
    it('throws UnauthorizedException when refresh token is invalid', async () => {
      mockTokenService.verifyAndDecode.mockReturnValue({ sub: 'user-1', iat: 0, exp: 0 });
      mockUsersService.verifyRefreshToken.mockResolvedValue(false);

      await expect(service.refreshToken('bad.refresh.token')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('returns new access_token when refresh token is valid', async () => {
      mockTokenService.verifyAndDecode.mockReturnValue({ sub: 'user-1', iat: 0, exp: 0 });
      mockUsersService.verifyRefreshToken.mockResolvedValue(true);

      const result = await service.refreshToken('valid.refresh.token');

      expect(result.access_token).toBe('new.access.token');
    });
  });

  describe('logout', () => {
    it('calls updateRefreshToken with null to clear the token', async () => {
      await service.logout('user-id-1');
      expect(mockUsersService.updateRefreshToken).toHaveBeenCalledWith('user-id-1', null);
    });
  });
});
