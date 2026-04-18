import { ApiProperty } from '@nestjs/swagger';

export class UserResponseDto {
  @ApiProperty({
    example: 'uuid-1234',
    description: 'User ID',
  })
  id: string;

  @ApiProperty({
    example: 'explorador123',
    description: 'Username',
  })
  username: string;

  @ApiProperty({
    example: 'user@example.com',
    description: 'Email address',
  })
  email: string;

  @ApiProperty({
    example: 'https://example.com/avatar.jpg',
    description: 'Avatar URL',
    nullable: true,
  })
  avatar_url: string | null;

  @ApiProperty({
    example: 'PUBLIC',
    description: 'Privacy mode',
  })
  privacy_mode: string;

  @ApiProperty({
    example: 45.3,
    description: 'Exploration percentage',
  })
  exploration_percent: number;

  @ApiProperty({
    example: 5420,
    description: 'Total XP points',
  })
  total_xp: number;

  @ApiProperty({
    example: 5,
    description: 'Number of medals',
  })
  medals_count: number;

  @ApiProperty({
    example: '2026-04-16T10:30:00Z',
    description: 'Creation date',
  })
  created_at: Date;

  @ApiProperty({
    example: '2026-04-16T14:30:00Z',
    description: 'Last update date',
  })
  updated_at: Date;
}

export class AuthResponseDto {
  @ApiProperty({
    description: 'User information',
  })
  user: UserResponseDto;

  @ApiProperty({
    description: 'Authentication tokens',
  })
  tokens: {
    @ApiProperty({
      example: 'eyJhbGc...',
      description: 'JWT access token',
    })
    access_token: string;

    @ApiProperty({
      example: 'eyJhbGc...',
      description: 'JWT refresh token',
    })
    refresh_token: string;

    @ApiProperty({
      example: 3600,
      description: 'Token expiration in seconds',
    })
    expires_in: number;
  };
}

export class RefreshTokenDto {
  @ApiProperty({
    example: 'eyJhbGc...',
    description: 'Refresh token',
  })
  refresh_token: string;
}

export class TokenResponseDto {
  @ApiProperty({
    example: 'eyJhbGc...',
    description: 'New access token',
  })
  access_token: string;

  @ApiProperty({
    example: 3600,
    description: 'Token expiration in seconds',
  })
  expires_in: number;
}
