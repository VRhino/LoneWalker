import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { typeOrmAsyncConfig } from './config/database.config';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ExplorationModule } from './modules/exploration/exploration.module';
import { TreasuresModule } from './modules/treasures/treasures.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    TypeOrmModule.forRootAsync(typeOrmAsyncConfig),
    // Feature modules
    AuthModule,
    UsersModule,
    ExplorationModule,
    TreasuresModule,
    // TBD: LandmarksModule,
    // TBD: RankingModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
