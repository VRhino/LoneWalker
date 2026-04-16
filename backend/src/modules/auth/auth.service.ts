import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { AuthResponseDto, TokenResponseDto } from './dto/auth-response.dto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  /**
   * Register a new user
   */
  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const { username, email, password, passwordConfirm } = registerDto;

    // Verify passwords match
    if (password !== passwordConfirm) {
      throw new BadRequestException('Passwords do not match');
    }

    // Create user
    const user = await this.usersService.create(username, email, password);

    // Generate tokens
    const tokens = this.generateTokens(user.id);

    // Update refresh token
    await this.usersService.updateRefreshToken(user.id, tokens.refresh_token);

    // Update last login
    await this.usersService.updateLastLogin(user.id);

    return {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        avatar_url: user.avatar_url,
        privacy_mode: user.privacy_mode,
        exploration_percent: user.exploration_percent,
        total_xp: user.total_xp,
        medals_count: user.medals_count,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
      tokens: {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        expires_in: this.configService.get<number>('JWT_EXPIRATION', 3600),
      },
    };
  }

  /**
   * Login user
   */
  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const { email, password } = loginDto;

    // Find user
    const user = await this.usersService.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Verify password
    const isPasswordValid = await this.usersService.verifyPassword(
      password,
      user.password_hash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Generate tokens
    const tokens = this.generateTokens(user.id);

    // Update refresh token
    await this.usersService.updateRefreshToken(user.id, tokens.refresh_token);

    // Update last login
    await this.usersService.updateLastLogin(user.id);

    return {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        avatar_url: user.avatar_url,
        privacy_mode: user.privacy_mode,
        exploration_percent: user.exploration_percent,
        total_xp: user.total_xp,
        medals_count: user.medals_count,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
      tokens: {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        expires_in: this.configService.get<number>('JWT_EXPIRATION', 3600),
      },
    };
  }

  /**
   * Refresh JWT token
   */
  async refreshToken(
    userId: string,
    refreshToken: string,
  ): Promise<TokenResponseDto> {
    // Verify refresh token
    const isValid = await this.usersService.verifyRefreshToken(
      userId,
      refreshToken,
    );

    if (!isValid) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    // Generate new access token
    const accessToken = this.jwtService.sign(
      { sub: userId },
      {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: this.configService.get<string>('JWT_EXPIRATION', '3600s'),
        algorithm: 'HS256',
      },
    );

    return {
      access_token: accessToken,
      expires_in: this.configService.get<number>('JWT_EXPIRATION', 3600),
    };
  }

  /**
   * Logout user (invalidate refresh token)
   */
  async logout(userId: string): Promise<void> {
    await this.usersService.updateRefreshToken(userId, null);
  }

  /**
   * Generate JWT tokens
   */
  private generateTokens(userId: string) {
    const accessToken = this.jwtService.sign(
      { sub: userId },
      {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: this.configService.get<string>('JWT_EXPIRATION', '3600s'),
        algorithm: 'HS256',
      },
    );

    const refreshToken = this.jwtService.sign(
      { sub: userId, type: 'refresh' },
      {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: this.configService.get<string>(
          'REFRESH_TOKEN_EXPIRATION',
          '604800s',
        ),
        algorithm: 'HS256',
      },
    );

    return { access_token: accessToken, refresh_token: refreshToken };
  }
}
