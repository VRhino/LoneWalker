import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { UserEntity } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private usersRepository: Repository<UserEntity>,
  ) {}

  /**
   * Create a new user
   */
  async create(
    username: string,
    email: string,
    password: string,
  ): Promise<UserEntity> {
    // Check if user already exists
    const existingUser = await this.usersRepository.findOne({
      where: [{ email }, { username }],
    });

    if (existingUser) {
      const field = existingUser.email === email ? 'Email' : 'Username';
      throw new ConflictException(`${field} already exists`);
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // Create user
    const user = this.usersRepository.create({
      username,
      email,
      password_hash,
    });

    return await this.usersRepository.save(user);
  }

  /**
   * Find user by email
   */
  async findByEmail(email: string): Promise<UserEntity | null> {
    return await this.usersRepository.findOne({ where: { email } });
  }

  /**
   * Find user by ID
   */
  async findById(id: string): Promise<UserEntity | null> {
    return await this.usersRepository.findOne({ where: { id } });
  }

  /**
   * Find user by username
   */
  async findByUsername(username: string): Promise<UserEntity | null> {
    return await this.usersRepository.findOne({ where: { username } });
  }

  /**
   * Verify password
   */
  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
  }

  /**
   * Update user refresh token
   */
  async updateRefreshToken(id: string, token: string | null): Promise<void> {
    let tokenHash: string | null = null;

    if (token) {
      const salt = await bcrypt.genSalt(10);
      tokenHash = await bcrypt.hash(token, salt);
    }

    await this.usersRepository.update(
      { id },
      { refresh_token_hash: tokenHash },
    );
  }

  /**
   * Verify refresh token
   */
  async verifyRefreshToken(id: string, token: string): Promise<boolean> {
    const user = await this.findById(id);

    if (!user || !user.refresh_token_hash) {
      return false;
    }

    return await bcrypt.compare(token, user.refresh_token_hash);
  }

  /**
   * Update last login timestamp
   */
  async updateLastLogin(id: string): Promise<void> {
    await this.usersRepository.update({ id }, { last_login_at: new Date() });
  }

  /**
   * Get user profile (public data)
   */
  async getUserProfile(id: string) {
    const user = await this.findById(id);

    if (!user) {
      throw new NotFoundException('User not found');
    }

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
      created_at: user.created_at,
      updated_at: user.updated_at,
    };
  }

  /**
   * Get public user profile (for viewing other users)
   */
  async getPublicProfile(id: string) {
    const user = await this.findById(id);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const profile: any = {
      id: user.id,
      username: user.username,
      avatar_url: user.avatar_url,
      medals_count: user.medals_count,
    };

    // Only show exploration and xp if user is public
    if (user.privacy_mode === 'PUBLIC') {
      profile.exploration_percent = user.exploration_percent;
      profile.total_xp = user.total_xp;
    }

    return profile;
  }
}
