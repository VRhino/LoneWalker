import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TreasuresService } from './treasures.service';
import { TreasuresController } from './treasures.controller';
import { TreasureEntity } from './entities/treasure.entity';
import { TreasureClaimEntity } from './entities/treasure-claim.entity';

@Module({
  imports: [TypeOrmModule.forFeature([TreasureEntity, TreasureClaimEntity])],
  controllers: [TreasuresController],
  providers: [TreasuresService],
  exports: [TreasuresService],
})
export class TreasuresModule {}
