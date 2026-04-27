import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RankingEntity } from './ranking.entity';
import { RankingService } from './ranking.service';
import { RankingController } from './ranking.controller';
import { UserEntity } from '../users/entities/user.entity';
import { TreasureClaimEntity } from '../treasures/entities/treasure-claim.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([RankingEntity, UserEntity, TreasureClaimEntity]),
  ],
  controllers: [RankingController],
  providers: [RankingService],
  exports: [RankingService],
})
export class RankingModule {}
