import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { UserEntity } from '../../users/entities/user.entity';

@Entity('exploration')
@Index('idx_exploration_user_id', ['user_id'])
@Index('idx_exploration_created', ['created_at'])
export class ExplorationEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @Column('numeric', { precision: 10, scale: 8 })
  latitude: number;

  @Column('numeric', { precision: 11, scale: 8 })
  longitude: number;

  @Column('numeric', { precision: 5, scale: 2, default: 0 })
  accuracy_meters: number;

  @Column('numeric', { precision: 5, scale: 2, default: 0 })
  speed_kmh: number;

  @CreateDateColumn()
  explored_at: Date;

  // PostGIS geometry column for spatial queries
  // Note: You need to enable PostGIS extension in PostgreSQL
  // CREATE EXTENSION IF NOT EXISTS postgis;
  @Column('geometry', {
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  location: string; // GeoJSON Point
}
