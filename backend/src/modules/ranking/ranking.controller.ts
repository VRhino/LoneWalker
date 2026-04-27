import {
  Controller,
  Get,
  Param,
  Query,
  UseGuards,
  ParseIntPipe,
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
import { RankingService } from './ranking.service';
import { RankingListDto, UserPositionDto } from './dto/ranking-response.dto';

@ApiTags('ranking')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('api/v1/ranking')
export class RankingController {
  constructor(private readonly rankingService: RankingService) {}

  @Get('global')
  @ApiOperation({ summary: 'Get global ranking' })
  @ApiResponse({ status: 200, type: RankingListDto })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  getGlobalRanking(
    @CurrentUser('id') userId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(50), ParseIntPipe) limit: number,
  ): Promise<RankingListDto> {
    return this.rankingService.getGlobalRanking(userId, page, limit);
  }

  @Get('weekly')
  @ApiOperation({ summary: 'Get weekly ranking' })
  @ApiResponse({ status: 200, type: RankingListDto })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  getWeeklyRanking(
    @CurrentUser('id') userId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(50), ParseIntPipe) limit: number,
  ): Promise<RankingListDto> {
    return this.rankingService.getWeeklyRanking(userId, page, limit);
  }

  @Get('district/:id')
  @ApiOperation({ summary: 'Get ranking by district' })
  @ApiResponse({ status: 200, type: RankingListDto })
  getDistrictRanking(
    @Param('id') districtId: string,
    @CurrentUser('id') userId: string,
  ): Promise<RankingListDto> {
    return this.rankingService.getDistrictRanking(districtId, userId);
  }

  @Get('position')
  @ApiOperation({ summary: 'Get current user ranking position' })
  @ApiResponse({ status: 200, type: UserPositionDto })
  getUserPosition(@CurrentUser('id') userId: string): Promise<UserPositionDto> {
    return this.rankingService.getUserPosition(userId);
  }
}
