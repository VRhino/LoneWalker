import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TreasuresService } from './treasures.service';
import { TreasuresController } from './treasures.controller';
import { TreasureEntity } from './entities/treasure.entity';
import { TreasureClaimEntity } from './entities/treasure-claim.entity';
import { UsersModule } from '../users/users.module';
import { MedalsModule } from '../medals/medals.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([TreasureEntity, TreasureClaimEntity]),
    UsersModule,
    MedalsModule,
  ],
  controllers: [TreasuresController],
  providers: [TreasuresService],
  exports: [TreasuresService],
})
export class TreasuresModule {}
