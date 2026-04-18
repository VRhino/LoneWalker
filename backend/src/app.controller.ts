import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiOkResponse } from '@nestjs/swagger';
import { AppService } from './app.service';

@ApiTags('Health')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Health check - Server is running' })
  @ApiOkResponse({
    description: 'Server health status',
    schema: {
      example: {
        status: 'ok',
        message: 'LoneWalker API is running',
        timestamp: '2026-04-16T08:00:00Z',
      },
    },
  })
  getHealth() {
    return this.appService.getHealth();
  }

  @Get('/api/v1/health')
  @ApiOperation({ summary: 'API health check' })
  @ApiOkResponse({
    description: 'API health status',
    schema: {
      example: {
        status: 'healthy',
        version: '0.1.0',
        environment: 'development',
      },
    },
  })
  getApiHealth() {
    return this.appService.getApiHealth();
  }
}
