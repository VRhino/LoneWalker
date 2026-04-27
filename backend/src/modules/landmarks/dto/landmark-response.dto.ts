import { ApiProperty } from '@nestjs/swagger';
import { LandmarkCategory, LandmarkStatus } from '../entities/landmark.entity';

export class LandmarkCommentDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  user_id: string;

  @ApiProperty()
  username: string;

  @ApiProperty()
  vote: number;

  @ApiProperty()
  comment: string;

  @ApiProperty()
  created_at: Date;
}

export class LandmarkDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  creator_id: string;

  @ApiProperty()
  creator_username: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty({ enum: LandmarkCategory })
  category: LandmarkCategory;

  @ApiProperty()
  latitude: number;

  @ApiProperty()
  longitude: number;

  @ApiProperty({ enum: LandmarkStatus })
  status: LandmarkStatus;

  @ApiProperty()
  votes_positive: number;

  @ApiProperty()
  votes_negative: number;

  @ApiProperty()
  net_votes: number;

  @ApiProperty({ required: false })
  photo_url: string | null;

  @ApiProperty()
  days_remaining: number;

  @ApiProperty()
  created_at: Date;

  @ApiProperty({ required: false })
  approved_at: Date | null;

  @ApiProperty({ required: false, type: [LandmarkCommentDto] })
  comments?: LandmarkCommentDto[];

  @ApiProperty({ required: false })
  user_vote?: number | null;
}
