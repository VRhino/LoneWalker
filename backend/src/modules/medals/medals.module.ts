import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MedalEntity } from './entities/medal.entity';
import { UserMedalEntity } from './entities/user-medal.entity';
import { MedalsService } from './medals.service';
import { MedalsController } from './medals.controller';
import { UsersModule } from '../users/users.module';
import { TreasureClaimEntity } from '../treasures/entities/treasure-claim.entity';
import { LandmarkVoteEntity } from '../landmarks/entities/landmark-vote.entity';
import { LandmarkEntity } from '../landmarks/entities/landmark.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      MedalEntity,
      UserMedalEntity,
      TreasureClaimEntity,
      LandmarkVoteEntity,
      LandmarkEntity,
    ]),
    UsersModule,
  ],
  controllers: [MedalsController],
  providers: [MedalsService],
  exports: [MedalsService],
})
export class MedalsModule {}
