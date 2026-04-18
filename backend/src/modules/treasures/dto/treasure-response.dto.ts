import { TreasureStatus, TreasureRarity } from '../entities/treasure.entity';

export class TreasureDto {
  id: string;
  title: string;
  description: string;
  latitude: number;
  longitude: number;
  status: TreasureStatus;
  rarity: TreasureRarity;
  max_uses: number;
  current_uses: number;
  uses_remaining: number;
  photo_url: string;
  stl_file_url: string;
  claimed_by_user: boolean;
  distance_meters?: number;
  created_at: Date;
  updated_at: Date;
}

export class TreasureClaimDto {
  id: string;
  treasure_id: string;
  treasure: TreasureDto;
  xp_earned: number;
  distance_meters: number;
  gps_validation_time_ms: number;
  claimed_at: Date;
}

export class TreasurerRadarDto {
  treasure_id: string;
  title: string;
  latitude: number;
  longitude: number;
  rarity: TreasureRarity;
  distance_meters: number;
  bearing_degrees: number;
  proximity_percent: number;
  can_claim: boolean;
}

export class TreasureWallOfFameDto {
  id: string;
  username: string;
  claimed_at: Date;
  xp_earned: number;
  distance_meters: number;
  gps_validation_time_ms: number;
}
