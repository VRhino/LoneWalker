import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { createClient } from 'redis';
import { CacheService } from './cache.service';

const mockRedisClient = {
  on: jest.fn(),
  connect: jest.fn(),
  get: jest.fn(),
  set: jest.fn(),
  del: jest.fn(),
  keys: jest.fn(),
  quit: jest.fn(),
};

jest.mock('redis', () => ({
  createClient: jest.fn(),
}));

const mockedCreateClient = createClient as jest.MockedFunction<
  typeof createClient
>;

function setupClientMock() {
  mockedCreateClient.mockReturnValue(
    mockRedisClient as unknown as ReturnType<typeof createClient>,
  );
  mockRedisClient.on.mockReturnValue(mockRedisClient);
  mockRedisClient.quit.mockResolvedValue(undefined);
}

async function buildService(connectSetup: () => void): Promise<CacheService> {
  setupClientMock();
  connectSetup();

  const module = await Test.createTestingModule({
    providers: [
      CacheService,
      {
        provide: ConfigService,
        useValue: { get: jest.fn((key: string, def?: unknown) => def) },
      },
    ],
  }).compile();

  const service = module.get(CacheService);
  await new Promise(r => setImmediate(r));
  return service;
}

describe('CacheService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns null when not connected (connect rejected)', async () => {
    const service = await buildService(() =>
      mockRedisClient.connect.mockRejectedValue(new Error('refused')),
    );

    const result = await service.get('any-key');
    expect(result).toBeNull();
  });

  it('set then get returns the stored value', async () => {
    const service = await buildService(() =>
      mockRedisClient.connect.mockResolvedValue(undefined),
    );
    const payload = { score: 42 };
    mockRedisClient.set.mockResolvedValue('OK');
    mockRedisClient.get.mockResolvedValue(JSON.stringify(payload));

    await service.set('test:key', payload, 60);
    const result = await service.get<typeof payload>('test:key');

    expect(mockRedisClient.set).toHaveBeenCalledWith(
      'test:key',
      JSON.stringify(payload),
      { EX: 60 },
    );
    expect(result).toEqual(payload);
  });

  it('del calls client.del with the correct key', async () => {
    const service = await buildService(() =>
      mockRedisClient.connect.mockResolvedValue(undefined),
    );
    mockRedisClient.del.mockResolvedValue(1);

    await service.del('some:key');

    expect(mockRedisClient.del).toHaveBeenCalledWith('some:key');
  });

  it('delPattern calls keys then del for matching keys', async () => {
    const service = await buildService(() =>
      mockRedisClient.connect.mockResolvedValue(undefined),
    );
    mockRedisClient.keys.mockResolvedValue(['ranking:1', 'ranking:2']);
    mockRedisClient.del.mockResolvedValue(2);

    await service.delPattern('ranking:*');

    expect(mockRedisClient.keys).toHaveBeenCalledWith('ranking:*');
    expect(mockRedisClient.del).toHaveBeenCalledWith([
      'ranking:1',
      'ranking:2',
    ]);
  });

  it('delPattern does not call del when no keys match', async () => {
    const service = await buildService(() =>
      mockRedisClient.connect.mockResolvedValue(undefined),
    );
    mockRedisClient.keys.mockResolvedValue([]);

    await service.delPattern('fog:user-1:*');

    expect(mockRedisClient.del).not.toHaveBeenCalled();
  });
});
