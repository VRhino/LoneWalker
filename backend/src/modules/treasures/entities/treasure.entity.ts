import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from '../../users/entities/user.entity';
import { TreasureClaimEntity } from './treasure-claim.entity';

export enum TreasureStatus {
  ACTIVE = 'ACTIVE',
  DEPLETED = 'DEPLETED',
  ARCHIVED = 'ARCHIVED',
}

export enum TreasureRarity {
  COMMON = 'COMMON',
  UNCOMMON = 'UNCOMMON',
  RARE = 'RARE',
  EPIC = 'EPIC',
  LEGENDARY = 'LEGENDARY',
}

@Entity('treasures')
@Index(['location'], { spatial: true })
@Index(['creator_id'])
@Index(['status'])
export class TreasureEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  creator_id: string;

  @ManyToOne(() => UserEntity)
  creator: UserEntity;

  @Column('varchar', { length: 200 })
  title: string;

  @Column('text', { nullable: true })
  description: string;

  @Column('decimal', { precision: 10, scale: 8 })
  latitude: number;

  @Column('decimal', { precision: 11, scale: 8 })
  longitude: number;

  @Column('simple-enum', {
    enum: TreasureStatus,
    default: TreasureStatus.ACTIVE,
  })
  status: TreasureStatus;

  @Column('simple-enum', {
    enum: TreasureRarity,
    default: TreasureRarity.COMMON,
  })
  rarity: TreasureRarity;

  @Column('int', { nullable: true })
  max_uses: number;

  @Column('int', { default: 0 })
  current_uses: number;

  @Column('varchar', { length: 500, nullable: true })
  photo_url: string;

  @Column('varchar', { length: 500, nullable: true })
  stl_file_url: string;

  @OneToMany(
    () => TreasureClaimEntity,
    (claim) => claim.treasure,
    { eager: false },
  )
  claims: TreasureClaimEntity[];

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @Column('geometry', {
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  location: string;
}
