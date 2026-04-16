import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHealth() {
    return {
      status: 'ok',
      message: 'LoneWalker API is running',
      timestamp: new Date().toISOString(),
    };
  }

  getApiHealth() {
    return {
      status: 'healthy',
      version: '0.1.0',
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString(),
    };
  }
}
