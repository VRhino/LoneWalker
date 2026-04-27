import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

export enum MedalRarity {
  COMMON = 'COMMON',
  UNCOMMON = 'UNCOMMON',
  RARE = 'RARE',
  EPIC = 'EPIC',
  LEGENDARY = 'LEGENDARY',
}

export enum MedalCategory {
  EXPLORATION = 'EXPLORATION',
  TREASURE = 'TREASURE',
  SOCIAL = 'SOCIAL',
  SPECIAL = 'SPECIAL',
}

export enum MedalKey {
  // Exploration
  FIRST_STEPS = 'FIRST_STEPS',
  EXPLORER_10 = 'EXPLORER_10',
  EXPLORER_25 = 'EXPLORER_25',
  EXPLORER_50 = 'EXPLORER_50',
  CONQUISTADOR = 'CONQUISTADOR',
  // Treasure
  FIRST_FINDER = 'FIRST_FINDER',
  TREASURE_SEEKER_10 = 'TREASURE_SEEKER_10',
  TREASURE_SEEKER_50 = 'TREASURE_SEEKER_50',
  TREASURE_SEEKER_100 = 'TREASURE_SEEKER_100',
  RARE_HUNTER_5 = 'RARE_HUNTER_5',
  RARE_HUNTER_20 = 'RARE_HUNTER_20',
  // Social
  VERIFIER_10 = 'VERIFIER_10',
  VERIFIER_50 = 'VERIFIER_50',
  CARTOGRAPHER_1 = 'CARTOGRAPHER_1',
  CARTOGRAPHER_5 = 'CARTOGRAPHER_5',
  CARTOGRAPHER_20 = 'CARTOGRAPHER_20',
  // Special
  MASTER_OF_MADRID = 'MASTER_OF_MADRID',
}

@Entity('medals')
export class MedalEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('varchar', { length: 50, unique: true })
  key: MedalKey;

  @Column('varchar', { length: 100 })
  name: string;

  @Column('text')
  description: string;

  @Column('varchar', { length: 500, nullable: true })
  icon_url: string | null;

  @Column('simple-enum', { enum: MedalRarity, default: MedalRarity.COMMON })
  rarity: MedalRarity;

  @Column('simple-enum', {
    enum: MedalCategory,
    default: MedalCategory.EXPLORATION,
  })
  category: MedalCategory;

  @Column('text')
  unlock_condition: string;

  @Column('integer', { default: 50 })
  xp_reward: number;

  @CreateDateColumn()
  created_at: Date;
}
