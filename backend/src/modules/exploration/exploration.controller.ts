import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Query,
  HttpCode,
  HttpStatus,
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

@ApiTags('Exploration')
@ApiBearerAuth('jwt')
@UseGuards(JwtAuthGuard)
@Controller('api/v1/exploration')
export class ExplorationController {
  constructor(private explorationService: ExplorationService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Register exploration point' })
  @ApiResponse({
    status: 201,
    description: 'Exploration registered successfully',
    type: ExplorationProgressDto,
  })
  @ApiResponse({
    status: 400,
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
    status: 200,
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
    status: 200,
    description: 'Map data with explored areas',
    type: FogOfWarDto,
  })
  async getMapWithFog(
    @CurrentUser('id') userId: string,
    @Query('lat') latitude: string,
    @Query('lng') longitude: string,
    @Query('radius') radius?: string,
  ): Promise<FogOfWarDto> {
    return await this.explorationService.getMapWithFog(
      userId,
      parseFloat(latitude),
      parseFloat(longitude),
      radius ? parseInt(radius) : 5000,
    );
  }

  @Get('last')
  @ApiOperation({ summary: 'Get last exploration' })
  @ApiResponse({
    status: 200,
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
    status: 200,
    description: 'Exploration history with pagination',
  })
  async getHistory(
    @CurrentUser('id') userId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return await this.explorationService.getExplorationHistory(
      userId,
      limit ? parseInt(limit) : 50,
      offset ? parseInt(offset) : 0,
    );
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get exploration statistics' })
  @ApiResponse({
    status: 200,
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
