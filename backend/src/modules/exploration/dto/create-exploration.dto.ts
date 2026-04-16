import { IsNumber, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateExplorationDto {
  @ApiProperty({
    example: 40.4168,
    description: 'Latitude coordinate',
  })
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({
    example: -3.7038,
    description: 'Longitude coordinate',
  })
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiProperty({
    example: 15,
    description: 'GPS accuracy in meters',
  })
  @IsNumber()
  @IsOptional()
  accuracy_meters?: number;

  @ApiProperty({
    example: 1.5,
    description: 'User speed in km/h',
  })
  @IsNumber()
  @IsOptional()
  speed_kmh?: number;

  @ApiProperty({
    example: '2026-04-16T14:30:00Z',
    description: 'Timestamp of the exploration',
  })
  @IsOptional()
  timestamp?: string;
}
