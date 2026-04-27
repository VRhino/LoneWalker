import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { UserEntity } from './entities/user.entity';
import { BCRYPT_SALT_ROUNDS } from '../../common/constants/auth.constants';
import { ERROR_MESSAGES } from '../../common/constants/error-messages.constants';
import { PrivacyMode } from '../../common/enums/privacy-mode.enum';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private usersRepository: Repository<UserEntity>,
  ) {}

  async create(
    username: string,
    email: string,
    password: string,
  ): Promise<UserEntity> {
    const existingUser = await this.usersRepository.findOne({
      where: [{ email }, { username }],
    });

    if (existingUser) {
      const field = existingUser.email === email ? 'Email' : 'Username';
      throw new ConflictException(`${field} already exists`);
    }

    const salt = await bcrypt.genSalt(BCRYPT_SALT_ROUNDS);
    const password_hash = await bcrypt.hash(password, salt);

    const user = this.usersRepository.create({
      username,
      email,
      password_hash,
    });

    return await this.usersRepository.save(user);
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    return await this.usersRepository.findOne({ where: { email } });
  }

  async findById(id: string): Promise<UserEntity | null> {
    return await this.usersRepository.findOne({ where: { id } });
  }

  async findByIdOrThrow(id: string): Promise<UserEntity> {
    const user = await this.findById(id);
    if (!user) {
      throw new NotFoundException(ERROR_MESSAGES.USER_NOT_FOUND);
    }
    return user;
  }

  async findByUsername(username: string): Promise<UserEntity | null> {
    return await this.usersRepository.findOne({ where: { username } });
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
  }

  async updateRefreshToken(id: string, token: string | null): Promise<void> {
    let tokenHash: string | null = null;

    if (token) {
      const salt = await bcrypt.genSalt(BCRYPT_SALT_ROUNDS);
      tokenHash = await bcrypt.hash(token, salt);
    }

    await this.usersRepository.update(
      { id },
      { refresh_token_hash: tokenHash },
    );
  }

  async verifyRefreshToken(id: string, token: string): Promise<boolean> {
    const user = await this.findById(id);

    if (!user || !user.refresh_token_hash) {
      return false;
    }

    return await bcrypt.compare(token, user.refresh_token_hash);
  }

  async updateLastLogin(id: string): Promise<void> {
    await this.usersRepository.update({ id }, { last_login_at: new Date() });
  }

  async updateExplorationStats(
    id: string,
    explorationPercent: number,
    totalXp: number,
  ): Promise<void> {
    await this.usersRepository.update(
      { id },
      { exploration_percent: explorationPercent, total_xp: totalXp },
    );
  }

  async getUserProfile(id: string) {
    const user = await this.findByIdOrThrow(id);

    return {
      id: user.id,
      username: user.username,
      email: user.email,
      avatar_url: user.avatar_url,
      bio: user.bio,
      privacy_mode: user.privacy_mode,
      exploration_percent: user.exploration_percent,
      total_xp: user.total_xp,
      medals_count: user.medals_count,
      cartographer_points: user.cartographer_points,
      created_at: user.created_at,
      updated_at: user.updated_at,
    };
  }

  async addXp(id: string, xpAmount: number): Promise<void> {
    await this.usersRepository.increment({ id }, 'total_xp', xpAmount);
  }

  async incrementMedalsCount(id: string): Promise<void> {
    await this.usersRepository.increment({ id }, 'medals_count', 1);
  }

  async findAllWithExploration(): Promise<UserEntity[]> {
    return this.usersRepository.find({
      where: { exploration_percent: MoreThan(0) },
      select: ['id', 'exploration_percent', 'total_xp'],
    });
  }

  async addCartographerPoints(id: string, points: number): Promise<void> {
    if (points >= 0) {
      await this.usersRepository.increment(
        { id },
        'cartographer_points',
        points,
      );
    } else {
      await this.usersRepository.decrement(
        { id },
        'cartographer_points',
        Math.abs(points),
      );
    }
  }

  async getPublicProfile(id: string) {
    const user = await this.findByIdOrThrow(id);

    const profile: Record<string, unknown> = {
      id: user.id,
      username: user.username,
      avatar_url: user.avatar_url,
      medals_count: user.medals_count,
    };

    if (user.privacy_mode === PrivacyMode.PUBLIC) {
      profile.exploration_percent = user.exploration_percent;
      profile.total_xp = user.total_xp;
    }

    return profile;
  }
}
