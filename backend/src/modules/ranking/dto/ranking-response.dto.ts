import { ApiProperty } from '@nestjs/swagger';

export class RankingEntryDto {
  @ApiProperty()
  rank: number;

  @ApiProperty()
  user_id: string;

  @ApiProperty()
  username: string;

  @ApiProperty({ required: false })
  avatar_url: string | null;

  @ApiProperty()
  exploration_percent: number;

  @ApiProperty()
  treasures_found: number;

  @ApiProperty()
  xp_total: number;

  @ApiProperty()
  medals_count: number;

  @ApiProperty()
  score: number;

  @ApiProperty()
  is_current_user: boolean;

  @ApiProperty()
  updated_at: Date;
}

export class UserPositionDto {
  @ApiProperty()
  rank: number;

  @ApiProperty()
  score: number;

  @ApiProperty()
  total_players: number;

  @ApiProperty()
  exploration_percent: number;

  @ApiProperty()
  treasures_found: number;

  @ApiProperty()
  xp_total: number;

  @ApiProperty()
  medals_count: number;
}

export class RankingListDto {
  @ApiProperty({ type: [RankingEntryDto] })
  entries: RankingEntryDto[];

  @ApiProperty()
  total: number;

  @ApiProperty()
  page: number;

  @ApiProperty()
  limit: number;
}
