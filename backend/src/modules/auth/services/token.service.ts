import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import {
  JWT_ALGORITHM,
  JWT_DEFAULT_EXPIRATION_S,
  JWT_EXPIRATION_KEY,
  JWT_SECRET_KEY,
  JWT_SUBJECT_CLAIM,
  JWT_TYPE_CLAIM,
  REFRESH_TOKEN_DEFAULT_EXPIRATION_S,
  REFRESH_TOKEN_EXPIRATION_KEY,
  REFRESH_TOKEN_TYPE,
} from '../../../common/constants/auth.constants';
import { JwtPayload } from '../../../common/interfaces/jwt-payload.interface';

@Injectable()
export class TokenService {
  constructor(
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  generateTokens(userId: string): {
    access_token: string;
    refresh_token: string;
  } {
    return {
      access_token: this.generateAccessToken(userId),
      refresh_token: this.generateRefreshToken(userId),
    };
  }

  generateAccessToken(userId: string): string {
    return this.jwtService.sign(
      { [JWT_SUBJECT_CLAIM]: userId },
      {
        secret: this.configService.get<string>(JWT_SECRET_KEY),
        expiresIn: Number(this.configService.get(JWT_EXPIRATION_KEY, JWT_DEFAULT_EXPIRATION_S)),
        algorithm: JWT_ALGORITHM,
      },
    );
  }

  private generateRefreshToken(userId: string): string {
    return this.jwtService.sign(
      { [JWT_SUBJECT_CLAIM]: userId, [JWT_TYPE_CLAIM]: REFRESH_TOKEN_TYPE },
      {
        secret: this.configService.get<string>(JWT_SECRET_KEY),
        expiresIn: Number(this.configService.get(REFRESH_TOKEN_EXPIRATION_KEY, REFRESH_TOKEN_DEFAULT_EXPIRATION_S)),
        algorithm: JWT_ALGORITHM,
      },
    );
  }

  verifyAndDecode(token: string): JwtPayload {
    try {
      return this.jwtService.verify<JwtPayload>(token, {
        secret: this.configService.get<string>(JWT_SECRET_KEY),
        algorithms: [JWT_ALGORITHM],
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}
