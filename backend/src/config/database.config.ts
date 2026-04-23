import { TypeOrmModuleAsyncOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

export const typeOrmAsyncConfig: TypeOrmModuleAsyncOptions = {
  useFactory: async (configService: ConfigService) => ({
    type: 'postgres',
    host: configService.get<string>('DB_HOST', 'localhost'),
    port: configService.get<number>('DB_PORT', 5432),
    username: configService.get<string>('DB_USER', 'postgres'),
    password: configService.getOrThrow<string>('DB_PASSWORD'),
    database: configService.get<string>('DB_NAME', 'lonewalker_dev'),
    synchronize: configService.get<boolean>('DB_SYNCHRONIZE', false),
    logging: configService.get<boolean>('DB_LOGGING', false),
    entities: ['dist/**/*.entity.js'],
    migrations: ['dist/migrations/*.js'],
    migrationsTableName: 'typeorm_migrations',
    subscribers: ['dist/**/*.subscriber.js'],
  }),
  inject: [ConfigService],
};
