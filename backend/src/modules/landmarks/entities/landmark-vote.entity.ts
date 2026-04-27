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
import { LandmarkEntity } from './landmark.entity';

@Entity('landmark_votes')
@Unique(['landmark_id', 'user_id'])
export class LandmarkVoteEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  landmark_id: string;

  @ManyToOne(() => LandmarkEntity, landmark => landmark.votes)
  @JoinColumn({ name: 'landmark_id' })
  landmark: LandmarkEntity;

  @Column('uuid')
  user_id: string;

  @ManyToOne(() => UserEntity)
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @Column('integer')
  vote: 1 | -1;

  @Column('text')
  comment: string;

  @CreateDateColumn()
  created_at: Date;
}
