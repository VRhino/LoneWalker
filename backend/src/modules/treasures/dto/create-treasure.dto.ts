import {
  IsString,
  IsNumber,
  IsOptional,
  IsEnum,
  Length,
  Min,
  Max,
} from 'class-validator';
import { TreasureRarity } from '../entities/treasure.entity';
import {
  WGS84_LAT_MIN,
  WGS84_LAT_MAX,
  WGS84_LNG_MIN,
  WGS84_LNG_MAX,
} from '../../../common/constants/geo.constants';

export class CreateTreasureDto {
  @IsString()
  @Length(3, 200)
  title: string;

  @IsString()
  @Length(10, 1000)
  description: string;

  @IsNumber()
  @Min(WGS84_LAT_MIN)
  @Max(WGS84_LAT_MAX)
  latitude: number;

  @IsNumber()
  @Min(WGS84_LNG_MIN)
  @Max(WGS84_LNG_MAX)
  longitude: number;

  @IsOptional()
  @IsEnum(TreasureRarity)
  rarity?: TreasureRarity;

  @IsOptional()
  @IsNumber()
  @Min(1)
  max_uses?: number;

  @IsOptional()
  @IsString()
  photo_url?: string;

  @IsOptional()
  @IsString()
  stl_file_url?: string;
}
