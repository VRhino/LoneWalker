import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { MedalsService } from './medals.service';
import { MedalDto } from './dto/medal-response.dto';

@ApiTags('medals')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('api/v1/medals')
export class MedalsController {
  constructor(private readonly medalsService: MedalsService) {}

  @Get()
  @ApiOperation({
    summary: 'Get all medals with unlock status for current user',
  })
  @ApiResponse({ status: 200, type: [MedalDto] })
  getUserMedals(@CurrentUser('id') userId: string): Promise<MedalDto[]> {
    return this.medalsService.getUserMedals(userId);
  }

  @Get('my')
  @ApiOperation({ summary: 'Get only unlocked medals for current user' })
  @ApiResponse({ status: 200, type: [MedalDto] })
  getUnlockedMedals(@CurrentUser('id') userId: string): Promise<MedalDto[]> {
    return this.medalsService.getUnlockedMedals(userId);
  }
}
