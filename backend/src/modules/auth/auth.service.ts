import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../users/users.service';
import { TokenService } from './services/token.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { AuthResponseDto, TokenResponseDto } from './dto/auth-response.dto';
import { UserEntity } from '../users/entities/user.entity';
import {
  JWT_DEFAULT_EXPIRATION_S,
  JWT_EXPIRATION_KEY,
} from '../../common/constants/auth.constants';
import { ERROR_MESSAGES } from '../../common/constants/error-messages.constants';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private tokenService: TokenService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const { username, email, password, passwordConfirm } = registerDto;

    if (password !== passwordConfirm) {
      throw new BadRequestException(ERROR_MESSAGES.PASSWORDS_DO_NOT_MATCH);
    }

    const user = await this.usersService.create(username, email, password);
    const tokens = this.tokenService.generateTokens(user.id);

    await this.usersService.updateRefreshToken(user.id, tokens.refresh_token);
    await this.usersService.updateLastLogin(user.id);

    return this.mapUserToResponse(user, tokens);
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const { email, password } = loginDto;

    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException(ERROR_MESSAGES.INVALID_CREDENTIALS);
    }

    const isPasswordValid = await this.usersService.verifyPassword(
      password,
      user.password_hash,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException(ERROR_MESSAGES.INVALID_CREDENTIALS);
    }

    const tokens = this.tokenService.generateTokens(user.id);

    await this.usersService.updateRefreshToken(user.id, tokens.refresh_token);
    await this.usersService.updateLastLogin(user.id);

    return this.mapUserToResponse(user, tokens);
  }

  async refreshToken(refreshToken: string): Promise<TokenResponseDto> {
    const payload = this.tokenService.verifyAndDecode(refreshToken);
    const userId = payload.sub;

    const isValid = await this.usersService.verifyRefreshToken(
      userId,
      refreshToken,
    );
    if (!isValid) {
      throw new UnauthorizedException(ERROR_MESSAGES.INVALID_REFRESH_TOKEN);
    }

    return {
      access_token: this.tokenService.generateAccessToken(userId),
      expires_in: this.configService.get<number>(
        JWT_EXPIRATION_KEY,
        JWT_DEFAULT_EXPIRATION_S,
      ),
    };
  }

  async logout(userId: string): Promise<void> {
    await this.usersService.updateRefreshToken(userId, null);
  }

  private mapUserToResponse(
    user: UserEntity,
    tokens: { access_token: string; refresh_token: string },
  ): AuthResponseDto {
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
        cartographer_points: user.cartographer_points,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
      tokens: {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        expires_in: this.configService.get<number>(
          JWT_EXPIRATION_KEY,
          JWT_DEFAULT_EXPIRATION_S,
        ),
      },
    };
  }
}
