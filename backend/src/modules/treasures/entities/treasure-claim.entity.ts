import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { UserEntity } from '../../users/entities/user.entity';
import { TreasureEntity } from './treasure.entity';

@Entity('treasure_claims')
@Unique('unique_user_treasure', ['user_id', 'treasure_id'])
@Index(['treasure_id'])
@Index(['user_id'])
@Index(['claimed_at'])
export class TreasureClaimEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @ManyToOne(() => UserEntity)
  user: UserEntity;

  @Column('uuid')
  treasure_id: string;

  @ManyToOne(() => TreasureEntity, (treasure) => treasure.claims)
  treasure: TreasureEntity;

  @Column('int')
  xp_earned: number;

  @Column('decimal', { precision: 3, scale: 1, default: 0 })
  distance_meters: number;

  @Column('int', { default: 0 })
  gps_validation_time_ms: number;

  @CreateDateColumn()
  claimed_at: Date;
}
