import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Unique,
} from 'typeorm';

@Entity('users')
@Unique(['email'])
@Unique(['username'])
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 50 })
  username: string;

  @Column({ type: 'varchar', length: 100 })
  email: string;

  @Column({ type: 'varchar', length: 255 })
  password_hash: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  avatar_url: string;

  @Column({ type: 'text', nullable: true })
  bio: string;

  @Column({
    type: 'varchar',
    length: 20,
    default: 'PUBLIC',
    enum: ['PUBLIC', 'PRIVATE'],
  })
  privacy_mode: 'PUBLIC' | 'PRIVATE';

  @Column({
    type: 'numeric',
    precision: 5,
    scale: 2,
    default: 0,
  })
  exploration_percent: number;

  @Column({ type: 'integer', default: 0 })
  total_xp: number;

  @Column({ type: 'integer', default: 0 })
  medals_count: number;

  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  @Column({ type: 'varchar', nullable: true })
  refresh_token_hash: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  last_login_at: Date;
}
