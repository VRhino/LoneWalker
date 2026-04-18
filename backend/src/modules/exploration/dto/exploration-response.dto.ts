import { ApiProperty } from '@nestjs/swagger';

export class ExplorationProgressDto {
  @ApiProperty({
    example: 'uuid-1234',
    description: 'User ID',
  })
  user_id: string;

  @ApiProperty({
    example: 45.3,
    description: 'Percentage of city explored',
  })
  exploration_percent: number;

  @ApiProperty({
    example: 5420,
    description: 'Total XP earned',
  })
  total_xp: number;

  @ApiProperty({
    example: 25.5,
    description: 'New areas cleared in this exploration (in %)',
  })
  new_areas_cleared: number;

  @ApiProperty({
    example: 50,
    description: 'XP earned from this exploration',
  })
  xp_earned: number;

  @ApiProperty({
    example: true,
    description: 'Whether fog of war was updated',
  })
  fog_updated: boolean;

  @ApiProperty({
    example: [
      {
        district_id: 'madrid_001',
        name: 'Centro Histórico',
        exploration_percent: 87.5,
        mastery_level: 'GOLD',
      },
    ],
    description: 'Current district exploration status',
  })
  districts_explored: Array<{
    district_id: string;
    name: string;
    exploration_percent: number;
    mastery_level: 'BRONZE' | 'SILVER' | 'GOLD' | 'PLATINUM';
  }>;
}

export class FogOfWarDto {
  @ApiProperty({
    example: {
      type: 'FeatureCollection',
      features: [],
    },
    description: 'GeoJSON FeatureCollection of explored areas',
  })
  fog_of_war: GeoJSON.FeatureCollection;

  @ApiProperty({
    description: 'Points of interest in the map area',
  })
  points_of_interest: Array<{
    id: string;
    name: string;
    latitude: number;
    longitude: number;
    type: string;
  }>;

  @ApiProperty({
    example: {
      latitude: 40.4168,
      longitude: -3.7038,
    },
    description: 'Current user position',
  })
  user_position: {
    latitude: number;
    longitude: number;
  };

  @ApiProperty({
    example: 45.3,
    description: 'Current exploration percentage',
  })
  exploration_percent: number;
}
