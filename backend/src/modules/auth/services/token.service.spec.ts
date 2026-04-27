import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';
import { TokenService } from './token.service';

describe('TokenService', () => {
  let service: TokenService;
  let jwtService: jest.Mocked<JwtService>;

  const mockJwtService = {
    sign: jest.fn().mockReturnValue('mock.jwt.token'),
    verify: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn().mockReturnValue('test-secret'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TokenService,
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<TokenService>(TokenService);
    jwtService = module.get(JwtService);
    jest.clearAllMocks();
    mockJwtService.sign.mockReturnValue('mock.jwt.token');
  });

  describe('generateTokens', () => {
    it('returns both access_token and refresh_token', () => {
      const tokens = service.generateTokens('user-1');
      expect(tokens).toHaveProperty('access_token');
      expect(tokens).toHaveProperty('refresh_token');
      expect(typeof tokens.access_token).toBe('string');
      expect(typeof tokens.refresh_token).toBe('string');
    });

    it('calls jwtService.sign twice', () => {
      service.generateTokens('user-1');
      expect(jwtService.sign).toHaveBeenCalledTimes(2);
    });
  });

  describe('generateAccessToken', () => {
    it('returns a string token', () => {
      const token = service.generateAccessToken('user-1');
      expect(typeof token).toBe('string');
      expect(jwtService.sign).toHaveBeenCalledTimes(1);
    });
  });

  describe('verifyAndDecode', () => {
    it('returns JwtPayload when token is valid', () => {
      const payload = { sub: 'user-1', iat: 1000, exp: 2000 };
      jwtService.verify.mockReturnValue(payload);
      const result = service.verifyAndDecode('valid.token');
      expect(result).toEqual(payload);
    });

    it('throws UnauthorizedException when jwtService.verify throws', () => {
      jwtService.verify.mockImplementation(() => {
        throw new Error('invalid signature');
      });
      expect(() => service.verifyAndDecode('bad.token')).toThrow(
        UnauthorizedException,
      );
    });

    it('throws UnauthorizedException when token is expired', () => {
      jwtService.verify.mockImplementation(() => {
        throw new Error('jwt expired');
      });
      expect(() => service.verifyAndDecode('expired.token')).toThrow(
        UnauthorizedException,
      );
    });
  });
});
