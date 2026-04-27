import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  Query,
  UseGuards,
  ParseFloatPipe,
  DefaultValuePipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { LandmarksService } from './landmarks.service';
import { CreateLandmarkDto } from './dto/create-landmark.dto';
import { VoteLandmarkDto } from './dto/vote-landmark.dto';
import { LandmarkDto, LandmarkCommentDto } from './dto/landmark-response.dto';

@ApiTags('landmarks')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('api/v1/landmarks')
export class LandmarksController {
  constructor(private readonly landmarksService: LandmarksService) {}

  @Post()
  @ApiOperation({ summary: 'Propose a new landmark' })
  @ApiResponse({ status: 201, type: LandmarkDto })
  proposeLandmark(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateLandmarkDto,
  ): Promise<LandmarkDto> {
    return this.landmarksService.proposeLandmark(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get landmarks (default: VOTING status)' })
  @ApiResponse({ status: 200, type: [LandmarkDto] })
  getLandmarks(@CurrentUser('id') userId: string): Promise<LandmarkDto[]> {
    return this.landmarksService.getLandmarksForVoting(userId);
  }

  @Get('approved')
  @ApiOperation({ summary: 'Get approved landmarks near location' })
  @ApiResponse({ status: 200, type: [LandmarkDto] })
  @ApiQuery({ name: 'lat', type: Number })
  @ApiQuery({ name: 'lng', type: Number })
  @ApiQuery({ name: 'radius', required: false, type: Number })
  getApprovedLandmarks(
    @Query('lat', ParseFloatPipe) lat: number,
    @Query('lng', ParseFloatPipe) lng: number,
    @Query('radius', new DefaultValuePipe(5000), ParseFloatPipe) radius: number,
  ): Promise<LandmarkDto[]> {
    return this.landmarksService.getApprovedLandmarks(lat, lng, radius);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get landmark details with votes' })
  @ApiResponse({ status: 200, type: LandmarkDto })
  getLandmarkById(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
  ): Promise<LandmarkDto> {
    return this.landmarksService.getLandmarkById(id, userId);
  }

  @Post(':id/votes')
  @ApiOperation({ summary: 'Vote on a landmark' })
  @ApiResponse({ status: 201, type: LandmarkDto })
  voteLandmark(
    @Param('id') landmarkId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: VoteLandmarkDto,
  ): Promise<LandmarkDto> {
    return this.landmarksService.voteLandmark(userId, landmarkId, dto);
  }

  @Get(':id/comments')
  @ApiOperation({ summary: 'Get landmark comments' })
  @ApiResponse({ status: 200, type: [LandmarkCommentDto] })
  getLandmarkComments(
    @Param('id') landmarkId: string,
  ): Promise<LandmarkCommentDto[]> {
    return this.landmarksService.getLandmarkComments(landmarkId);
  }
}
