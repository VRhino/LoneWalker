import { UserEntity } from '../../modules/users/entities/user.entity';
import {
  TreasureEntity,
  TreasureStatus,
  TreasureRarity,
} from '../../modules/treasures/entities/treasure.entity';
import {
  LandmarkEntity,
  LandmarkStatus,
  LandmarkCategory,
} from '../../modules/landmarks/entities/landmark.entity';
import { MedalEntity, MedalKey, MedalRarity, MedalCategory } from '../../modules/medals/entities/medal.entity';
import { PrivacyMode } from '../enums/privacy-mode.enum';

export function makeUser(overrides: Partial<UserEntity> = {}): UserEntity {
  return {
    id: 'user-id-1',
    username: 'testuser',
    email: 'test@example.com',
    password_hash: '$2b$10$hashedpassword',
    avatar_url: null,
    bio: null,
    privacy_mode: PrivacyMode.PUBLIC,
    exploration_percent: 0,
    total_xp: 0,
    medals_count: 0,
    cartographer_points: 0,
    is_active: true,
    refresh_token_hash: null,
    created_at: new Date('2024-01-01'),
    updated_at: new Date('2024-01-01'),
    last_login_at: null,
    ...overrides,
  } as UserEntity;
}

export function makeTreasure(
  overrides: Partial<TreasureEntity> = {},
): TreasureEntity {
  return {
    id: 'treasure-id-1',
    creator_id: 'user-id-1',
    creator: makeUser(),
    title: 'Test Treasure',
    description: 'A test treasure',
    latitude: 40.4168,
    longitude: -3.7038,
    status: TreasureStatus.ACTIVE,
    rarity: TreasureRarity.COMMON,
    max_uses: null,
    current_uses: 0,
    photo_url: null,
    stl_file_url: null,
    claims: [],
    location: 'POINT(-3.7038 40.4168)',
    created_at: new Date('2024-01-01'),
    updated_at: new Date('2024-01-01'),
    ...overrides,
  } as TreasureEntity;
}

export function makeLandmark(
  overrides: Partial<LandmarkEntity> = {},
): LandmarkEntity {
  return {
    id: 'landmark-id-1',
    creator_id: 'user-id-1',
    creator: makeUser(),
    title: 'Test Landmark',
    description: 'A test landmark',
    category: LandmarkCategory.MONUMENT,
    latitude: 40.4168,
    longitude: -3.7038,
    status: LandmarkStatus.VOTING,
    votes_positive: 0,
    votes_negative: 0,
    photo_url: null,
    votes: [],
    location: 'POINT(-3.7038 40.4168)',
    created_at: new Date('2024-01-01'),
    approved_at: null,
    ...overrides,
  } as LandmarkEntity;
}

export function makeMedal(overrides: Partial<MedalEntity> = {}): MedalEntity {
  return {
    id: 'medal-id-1',
    key: MedalKey.FIRST_STEPS,
    name: 'First Steps',
    description: 'Register your first exploration point',
    icon_url: null,
    rarity: MedalRarity.COMMON,
    category: MedalCategory.EXPLORATION,
    unlock_condition: 'exploration_percent >= 0.5',
    xp_reward: 50,
    created_at: new Date('2024-01-01'),
    ...overrides,
  } as MedalEntity;
}

export function mockRepo<T>() {
  return {
    find: jest.fn(),
    findOne: jest.fn(),
    findOneBy: jest.fn(),
    findBy: jest.fn(),
    findAndCount: jest.fn(),
    save: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    increment: jest.fn(),
    decrement: jest.fn(),
    count: jest.fn(),
    createQueryBuilder: jest.fn(),
  } as unknown as jest.Mocked<{
    find: () => Promise<T[]>;
    findOne: () => Promise<T | null>;
    findOneBy: () => Promise<T | null>;
    findBy: () => Promise<T[]>;
    findAndCount: () => Promise<[T[], number]>;
    save: (entity: T) => Promise<T>;
    create: (dto: Partial<T>) => T;
    update: () => Promise<void>;
    increment: () => Promise<void>;
    decrement: () => Promise<void>;
    count: () => Promise<number>;
    createQueryBuilder: () => ReturnType<typeof mockQueryBuilder>;
  }>;
}

export function mockQueryBuilder(result: unknown = []) {
  const qb = {
    select: jest.fn(),
    addSelect: jest.fn(),
    where: jest.fn(),
    andWhere: jest.fn(),
    innerJoin: jest.fn(),
    innerJoinAndSelect: jest.fn(),
    leftJoinAndSelect: jest.fn(),
    orderBy: jest.fn(),
    addOrderBy: jest.fn(),
    groupBy: jest.fn(),
    limit: jest.fn(),
    skip: jest.fn(),
    take: jest.fn(),
    setParameters: jest.fn(),
    insert: jest.fn(),
    into: jest.fn(),
    values: jest.fn(),
    orUpdate: jest.fn(),
    execute: jest.fn().mockResolvedValue(undefined),
    getRawMany: jest.fn().mockResolvedValue(result),
    getMany: jest.fn().mockResolvedValue(result),
    getManyAndCount: jest.fn().mockResolvedValue([result, (result as unknown[]).length]),
    getCount: jest.fn().mockResolvedValue(0),
  };

  // All fluent methods return this
  const fluent = ['select', 'addSelect', 'where', 'andWhere', 'innerJoin',
    'innerJoinAndSelect', 'leftJoinAndSelect', 'orderBy', 'addOrderBy',
    'groupBy', 'limit', 'skip', 'take', 'setParameters',
    'insert', 'into', 'values', 'orUpdate'];
  fluent.forEach(m => (qb as Record<string, jest.Mock>)[m].mockReturnValue(qb));

  return qb;
}
