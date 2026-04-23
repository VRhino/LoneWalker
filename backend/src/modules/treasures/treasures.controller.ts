import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { TreasuresService } from './treasures.service';
import { CreateTreasureDto } from './dto/create-treasure.dto';
import { ClaimTreasureDto } from './dto/claim-treasure.dto';
import { TreasureDto, TreasurerRadarDto } from './dto/treasure-response.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DEFAULT_SEARCH_RADIUS_M } from '../../common/constants/geo.constants';
import { SWAGGER_BEARER_SECURITY_KEY } from '../../common/constants/app.constants';

@ApiTags('Treasures')
@Controller('api/v1/treasures')
export class TreasuresController {
  constructor(private readonly treasuresService: TreasuresService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(SWAGGER_BEARER_SECURITY_KEY)
  @ApiOperation({ summary: 'Create a new treasure' })
  async createTreasure(
    @CurrentUser('id') userId: string,
    @Body() createTreasureDto: CreateTreasureDto,
  ): Promise<TreasureDto> {
    return this.treasuresService.createTreasure(userId, createTreasureDto);
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Get treasures nearby user location' })
  async getNearby(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('radius') radius: number = DEFAULT_SEARCH_RADIUS_M,
    @CurrentUser('id') userId?: string,
  ): Promise<TreasureDto[]> {
    return this.treasuresService.getTreasuresNearby(
      Number(latitude),
      Number(longitude),
      Number(radius),
      userId,
    );
  }

  @Get('radar')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(SWAGGER_BEARER_SECURITY_KEY)
  @ApiOperation({ summary: 'Get radar data for nearby treasures' })
  async getRadar(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @CurrentUser('id') userId: string,
  ): Promise<TreasurerRadarDto[]> {
    return this.treasuresService.getRadarData(
      Number(latitude),
      Number(longitude),
      userId,
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get treasure details' })
  async getTreasure(
    @Param('id') treasureId: string,
    @CurrentUser('id') userId?: string,
  ): Promise<TreasureDto> {
    return this.treasuresService.getTreasureById(treasureId, userId);
  }

  @Post(':id/claim')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(SWAGGER_BEARER_SECURITY_KEY)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Claim a treasure' })
  async claimTreasure(
    @Param('id') treasureId: string,
    @Body() claimData: ClaimTreasureDto,
    @CurrentUser('id') userId: string,
  ): Promise<{
    treasure: TreasureDto;
    xpEarned: number;
    claimed: boolean;
    message: string;
  }> {
    const result = await this.treasuresService.claimTreasure(
      userId,
      treasureId,
      claimData.latitude,
      claimData.longitude,
      claimData.accuracy_meters,
    );

    return {
      ...result,
      message: `Treasure claimed! +${result.xpEarned} XP earned`,
    };
  }

  @Get(':id/wall-of-fame')
  @ApiOperation({ summary: 'Get wall of fame for a treasure' })
  async getWallOfFame(@Param('id') treasureId: string) {
    return this.treasuresService.getTreasureWallOfFame(treasureId);
  }

  @Get('stats/claims')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth(SWAGGER_BEARER_SECURITY_KEY)
  @ApiOperation({ summary: 'Get treasure claims statistics' })
  async getClaimsStats(@CurrentUser('id') userId: string) {
    return this.treasuresService.getTreasureClaimsStats(userId);
  }
}
