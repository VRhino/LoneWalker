import { IsString, IsNumber, IsOptional, IsEnum, Length, Min, Max } from 'class-validator';
import { TreasureRarity } from '../entities/treasure.entity';

export class CreateTreasureDto {
  @IsString()
  @Length(3, 200)
  title: string;

  @IsString()
  @Length(10, 1000)
  description: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
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
