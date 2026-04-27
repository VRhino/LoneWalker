import { TypeOrmModuleAsyncOptions, TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

function buildConnectionOptions(configService: ConfigService): TypeOrmModuleOptions {
  const databaseUrl = configService.get<string>('DATABASE_URL');
  const base = {
    type: 'postgres' as const,
    synchronize: configService.get<boolean>('DB_SYNCHRONIZE', false),
    logging: configService.get<boolean>('DB_LOGGING', false),
    entities: ['dist/**/*.entity.js'],
    migrations: ['dist/migrations/*.js'],
    migrationsTableName: 'typeorm_migrations',
    subscribers: ['dist/**/*.subscriber.js'],
  };

  if (databaseUrl) {
    return { ...base, url: databaseUrl, ssl: { rejectUnauthorized: false } };
  }

  return {
    ...base,
    host: configService.get<string>('DB_HOST', 'localhost'),
    port: configService.get<number>('DB_PORT', 5432),
    username: configService.get<string>('DB_USER', 'postgres'),
    password: configService.getOrThrow<string>('DB_PASSWORD'),
    database: configService.get<string>('DB_NAME', 'lonewalker_dev'),
  };
}

export const typeOrmAsyncConfig: TypeOrmModuleAsyncOptions = {
  useFactory: async (configService: ConfigService) => buildConnectionOptions(configService),
  inject: [ConfigService],
};
