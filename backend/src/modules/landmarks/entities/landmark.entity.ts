import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from '../../users/entities/user.entity';
import { LandmarkVoteEntity } from './landmark-vote.entity';
import { SRID_WGS84 } from '../../../common/constants/geo.constants';

export enum LandmarkStatus {
  DRAFT = 'DRAFT',
  VOTING = 'VOTING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export enum LandmarkCategory {
  MONUMENT = 'MONUMENT',
  MURAL = 'MURAL',
  ARCHITECTURE = 'ARCHITECTURE',
  NATURE = 'NATURE',
  CULTURE = 'CULTURE',
  GASTRONOMY = 'GASTRONOMY',
  HISTORY = 'HISTORY',
  OTHER = 'OTHER',
}

@Entity('landmarks')
@Index(['location'], { spatial: true })
@Index(['creator_id'])
@Index(['status'])
export class LandmarkEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  creator_id: string;

  @ManyToOne(() => UserEntity)
  @JoinColumn({ name: 'creator_id' })
  creator: UserEntity;

  @Column('varchar', { length: 200 })
  title: string;

  @Column('text')
  description: string;

  @Column('simple-enum', {
    enum: LandmarkCategory,
    default: LandmarkCategory.OTHER,
  })
  category: LandmarkCategory;

  @Column('decimal', { precision: 10, scale: 8 })
  latitude: number;

  @Column('decimal', { precision: 11, scale: 8 })
  longitude: number;

  @Column('simple-enum', {
    enum: LandmarkStatus,
    default: LandmarkStatus.VOTING,
  })
  status: LandmarkStatus;

  @Column('integer', { default: 0 })
  votes_positive: number;

  @Column('integer', { default: 0 })
  votes_negative: number;

  @Column('varchar', { length: 500, nullable: true })
  photo_url: string | null;

  @OneToMany(() => LandmarkVoteEntity, vote => vote.landmark, { eager: false })
  votes: LandmarkVoteEntity[];

  @CreateDateColumn()
  created_at: Date;

  @Column('timestamp', { nullable: true })
  approved_at: Date | null;

  @Column('geometry', {
    spatialFeatureType: 'Point',
    srid: SRID_WGS84,
    nullable: true,
  })
  location: string;
}
