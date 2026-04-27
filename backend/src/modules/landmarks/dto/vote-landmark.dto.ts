import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsString, MinLength, IsIn } from 'class-validator';

export class VoteLandmarkDto {
  @ApiProperty({ description: '+1 to support, -1 to oppose', enum: [1, -1] })
  @IsNumber()
  @IsIn([1, -1])
  vote: 1 | -1;

  @ApiProperty({
    description: 'Mandatory comment explaining the vote',
    minLength: 10,
  })
  @IsString()
  @MinLength(10)
  comment: string;
}
