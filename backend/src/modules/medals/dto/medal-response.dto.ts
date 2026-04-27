import { ApiProperty } from '@nestjs/swagger';
import { MedalCategory, MedalRarity } from '../entities/medal.entity';

export class MedalDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  key: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  description: string;

  @ApiProperty({ required: false })
  icon_url: string | null;

  @ApiProperty({ enum: MedalRarity })
  rarity: MedalRarity;

  @ApiProperty({ enum: MedalCategory })
  category: MedalCategory;

  @ApiProperty()
  unlock_condition: string;

  @ApiProperty()
  xp_reward: number;

  @ApiProperty()
  unlocked: boolean;

  @ApiProperty({ required: false })
  unlocked_at: Date | null;
}
