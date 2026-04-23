import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Query,
  HttpCode,
  HttpStatus,
  DefaultValuePipe,
  ParseIntPipe,
  ParseFloatPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ExplorationService } from './services/exploration.service';
import { CreateExplorationDto } from './dto/create-exploration.dto';
import {
  ExplorationProgressDto,
  FogOfWarDto,
} from './dto/exploration-response.dto';
import { DEFAULT_SEARCH_RADIUS_M } from '../../common/constants/geo.constants';
import { SWAGGER_BEARER_SECURITY_KEY } from '../../common/constants/app.constants';

const DEFAULT_PAGE_LIMIT = 50;

@ApiTags('Exploration')
@ApiBearerAuth(SWAGGER_BEARER_SECURITY_KEY)
@UseGuards(JwtAuthGuard)
@Controller('api/v1/exploration')
export class ExplorationController {
  constructor(private explorationService: ExplorationService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Register exploration point' })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Exploration registered successfully',
    type: ExplorationProgressDto,
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Speed limit exceeded or GPS accuracy too low',
  })
  async registerExploration(
    @CurrentUser('id') userId: string,
    @Body() createExplorationDto: CreateExplorationDto,
  ): Promise<ExplorationProgressDto> {
    return await this.explorationService.registerExploration(
      userId,
      createExplorationDto,
    );
  }

  @Get('progress')
  @ApiOperation({ summary: 'Get exploration progress' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Current exploration progress',
    type: ExplorationProgressDto,
  })
  async getProgress(
    @CurrentUser('id') userId: string,
  ): Promise<ExplorationProgressDto> {
    return await this.explorationService.getExplorationProgress(userId);
  }

  @Get('map')
  @ApiOperation({ summary: 'Get map with fog of war' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Map data with explored areas',
    type: FogOfWarDto,
  })
  async getMapWithFog(
    @CurrentUser('id') userId: string,
    @Query('lat', ParseFloatPipe) latitude: number,
    @Query('lng', ParseFloatPipe) longitude: number,
    @Query(
      'radius',
      new DefaultValuePipe(DEFAULT_SEARCH_RADIUS_M),
      ParseIntPipe,
    )
    radius: number,
  ): Promise<FogOfWarDto> {
    return await this.explorationService.getMapWithFog(
      userId,
      latitude,
      longitude,
      radius,
    );
  }

  @Get('last')
  @ApiOperation({ summary: 'Get last exploration' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Last exploration point',
    schema: {
      example: {
        id: 'uuid',
        user_id: 'uuid',
        latitude: 40.4168,
        longitude: -3.7038,
        explored_at: '2026-04-16T14:30:00Z',
      },
    },
  })
  async getLastExploration(@CurrentUser('id') userId: string) {
    return await this.explorationService.getLastExploration(userId);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get exploration history' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Exploration history with pagination',
  })
  async getHistory(
    @CurrentUser('id') userId: string,
    @Query('limit', new DefaultValuePipe(DEFAULT_PAGE_LIMIT), ParseIntPipe)
    limit: number,
    @Query('offset', new DefaultValuePipe(0), ParseIntPipe) offset: number,
  ) {
    return await this.explorationService.getExplorationHistory(
      userId,
      limit,
      offset,
    );
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get exploration statistics' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Exploration statistics',
  })
  async getStats(
    @CurrentUser('id') userId: string,
    @Query('start') startDate: string,
    @Query('end') endDate: string,
  ) {
    return await this.explorationService.getExplorationStats(
      userId,
      new Date(startDate),
      new Date(endDate),
    );
  }
}
