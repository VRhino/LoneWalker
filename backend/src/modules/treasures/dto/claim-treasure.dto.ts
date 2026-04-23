import { IsNumber, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import {
  WGS84_LAT_MIN,
  WGS84_LAT_MAX,
  WGS84_LNG_MIN,
  WGS84_LNG_MAX,
} from '../../../common/constants/geo.constants';

export class ClaimTreasureDto {
  @ApiProperty({ example: 40.4168, description: 'Latitude coordinate' })
  @IsNumber()
  @Min(WGS84_LAT_MIN)
  @Max(WGS84_LAT_MAX)
  latitude: number;

  @ApiProperty({ example: -3.7038, description: 'Longitude coordinate' })
  @IsNumber()
  @Min(WGS84_LNG_MIN)
  @Max(WGS84_LNG_MAX)
  longitude: number;

  @ApiProperty({ example: 10, description: 'GPS accuracy in meters' })
  @IsNumber()
  @Min(0)
  accuracy_meters: number;
}
