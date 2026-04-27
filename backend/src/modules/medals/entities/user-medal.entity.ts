import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Unique,
} from 'typeorm';
import { UserEntity } from '../../users/entities/user.entity';
import { MedalEntity } from './medal.entity';

@Entity('user_medals')
@Unique(['user_id', 'medal_id'])
export class UserMedalEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @ManyToOne(() => UserEntity)
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @Column('uuid')
  medal_id: string;

  @ManyToOne(() => MedalEntity)
  @JoinColumn({ name: 'medal_id' })
  medal: MedalEntity;

  @CreateDateColumn()
  unlocked_at: Date;
}
