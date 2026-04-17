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
import { TreasureDto, TreasurerRadarDto } from './dto/treasure-response.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('treasures')
@Controller('api/v1/treasures')
export class TreasuresController {
  constructor(private readonly treasuresService: TreasuresService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new treasure' })
  async createTreasure(
    @CurrentUser() userId: string,
    @Body() createTreasureDto: CreateTreasureDto,
  ): Promise<TreasureDto> {
    return this.treasuresService.createTreasure(userId, createTreasureDto);
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Get treasures nearby user location' })
  async getNearby(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('radius') radius?: number,
    @CurrentUser() userId?: string,
  ): Promise<TreasureDto[]> {
    return this.treasuresService.getTreasuresNearby(
      Number(latitude),
      Number(longitude),
      radius ? Number(radius) : 5000,
      userId,
    );
  }

  @Get('radar')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get radar data for nearby treasures' })
  async getRadar(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @CurrentUser() userId: string,
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
    @CurrentUser() userId?: string,
  ): Promise<TreasureDto> {
    return this.treasuresService.getTreasureById(treasureId, userId);
  }

  @Post(':id/claim')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Claim a treasure' })
  async claimTreasure(
    @Param('id') treasureId: string,
    @Body()
    claimData: {
      latitude: number;
      longitude: number;
      accuracy_meters: number;
    },
    @CurrentUser() userId: string,
  ): Promise<{
    treasure: TreasureDto;
    xpEarned: number;
    claimed: boolean;
    message: string;
  }> {
    const result = await this.treasuresService.claimTreasure(
      userId,
      treasureId,
      Number(claimData.latitude),
      Number(claimData.longitude),
      Number(claimData.accuracy_meters),
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
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get treasure claims statistics' })
  async getClaimsStats(@CurrentUser() userId: string) {
    return this.treasuresService.getTreasureClaimsStats(userId);
  }
}
