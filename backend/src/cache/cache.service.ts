import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, RedisClientType } from 'redis';

@Injectable()
export class CacheService implements OnModuleDestroy {
  private readonly logger = new Logger(CacheService.name);
  private client: RedisClientType;
  private connected = false;

  constructor(private readonly config: ConfigService) {
    const url = this.config.get<string>('REDIS_URL');

    if (url) {
      this.client = createClient({ url }) as RedisClientType;
    } else {
      const password = this.config.get<string>('REDIS_PASSWORD');
      this.client = createClient({
        socket: {
          host: this.config.get<string>('REDIS_HOST', 'localhost'),
          port: this.config.get<number>('REDIS_PORT', 6379),
        },
        ...(password ? { password } : {}),
        database: this.config.get<number>('REDIS_DB', 0),
      }) as RedisClientType;
    }

    this.client.on('error', err =>
      this.logger.warn('Redis error', err.message),
    );

    this.client
      .connect()
      .then(() => {
        this.connected = true;
        this.logger.log('Redis connected');
      })
      .catch(err => {
        this.logger.warn(`Redis unavailable, caching disabled: ${err.message}`);
      });
  }

  async get<T>(key: string): Promise<T | null> {
    if (!this.connected) return null;
    try {
      const val = await this.client.get(key);
      return val ? (JSON.parse(val) as T) : null;
    } catch {
      return null;
    }
  }

  async set(key: string, value: unknown, ttlSeconds: number): Promise<void> {
    if (!this.connected) return;
    try {
      await this.client.set(key, JSON.stringify(value), { EX: ttlSeconds });
    } catch (err) {
      this.logger.warn(`Cache set failed [${key}]: ${(err as Error).message}`);
    }
  }

  async del(key: string): Promise<void> {
    if (!this.connected) return;
    try {
      await this.client.del(key);
    } catch (err) {
      this.logger.warn(`Cache del failed [${key}]: ${(err as Error).message}`);
    }
  }

  async delPattern(pattern: string): Promise<void> {
    if (!this.connected) return;
    try {
      const keys = await this.client.keys(pattern);
      if (keys.length > 0) {
        await this.client.del(keys);
      }
    } catch (err) {
      this.logger.warn(
        `Cache delPattern failed [${pattern}]: ${(err as Error).message}`,
      );
    }
  }

  async onModuleDestroy(): Promise<void> {
    if (this.connected) {
      await this.client.quit();
    }
  }
}
