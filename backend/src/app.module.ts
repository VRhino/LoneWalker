import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { typeOrmAsyncConfig } from './config/database.config';
import { CacheModule } from './cache/cache.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ExplorationModule } from './modules/exploration/exploration.module';
import { TreasuresModule } from './modules/treasures/treasures.module';
import { MedalsModule } from './modules/medals/medals.module';
import { LandmarksModule } from './modules/landmarks/landmarks.module';
import { RankingModule } from './modules/ranking/ranking.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    TypeOrmModule.forRootAsync(typeOrmAsyncConfig),
    ScheduleModule.forRoot(),
    CacheModule,
    // Feature modules
    AuthModule,
    UsersModule,
    MedalsModule,
    ExplorationModule,
    TreasuresModule,
    LandmarksModule,
    RankingModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
