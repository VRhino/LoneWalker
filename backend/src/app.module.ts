import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { typeOrmAsyncConfig } from './config/database.config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    TypeOrmModule.forRootAsync(typeOrmAsyncConfig),
    // Feature modules will be imported here in future phases
    // AuthModule,
    // UsersModule,
    // ExplorationModule,
    // TreasuresModule,
    // LandmarksModule,
    // RankingModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
