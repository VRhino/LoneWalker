import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExplorationEntity } from './entities/exploration.entity';
import { ExplorationService } from './services/exploration.service';
import { ExplorationController } from './exploration.controller';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [TypeOrmModule.forFeature([ExplorationEntity]), UsersModule],
  providers: [ExplorationService],
  controllers: [ExplorationController],
  exports: [ExplorationService],
})
export class ExplorationModule {}
