import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  UpdateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { UserEntity } from '../users/entities/user.entity';

@Entity('rankings')
@Unique(['user_id'])
@Index(['score'])
export class RankingEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @ManyToOne(() => UserEntity)
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @Column('integer', { default: 0 })
  rank: number;

  @Column('decimal', { precision: 5, scale: 2, default: 0 })
  exploration_percent: number;

  @Column('integer', { default: 0 })
  treasures_found: number;

  @Column('integer', { default: 0 })
  xp_total: number;

  @Column('integer', { default: 0 })
  medals_count: number;

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  score: number;

  @UpdateDateColumn()
  updated_at: Date;
}
