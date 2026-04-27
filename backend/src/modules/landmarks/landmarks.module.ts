import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LandmarkEntity } from './entities/landmark.entity';
import { LandmarkVoteEntity } from './entities/landmark-vote.entity';
import { LandmarksService } from './landmarks.service';
import { LandmarksController } from './landmarks.controller';
import { UsersModule } from '../users/users.module';
import { MedalsModule } from '../medals/medals.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([LandmarkEntity, LandmarkVoteEntity]),
    UsersModule,
    MedalsModule,
  ],
  controllers: [LandmarksController],
  providers: [LandmarksService],
  exports: [LandmarksService],
})
export class LandmarksModule {}
