import { INestApplication, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';
import {
  DEFAULT_APP_PORT,
  SWAGGER_DOCS_PATH,
  SWAGGER_BEARER_SECURITY_KEY,
} from './common/constants/app.constants';

function configureMiddleware(app: INestApplication): void {
  app.use(helmet());
  app.enableCors({
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    credentials: process.env.CORS_CREDENTIALS === 'true',
  });
}

function configureValidation(app: INestApplication): void {
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
}

function configureSwagger(app: INestApplication): void {
  const config = new DocumentBuilder()
    .setTitle('LoneWalker API')
    .setDescription('GPS-based exploration gamification API')
    .setVersion('0.1.0')
    .addBearerAuth(
      { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      SWAGGER_BEARER_SECURITY_KEY,
    )
    .addTag('Auth', 'Authentication endpoints')
    .addTag('Exploration', 'Map and exploration endpoints')
    .addTag('Treasures', 'Treasure hunt endpoints')
    .addTag('Landmarks', 'Community landmarks endpoints')
    .addTag('Ranking', 'User ranking endpoints')
    .addTag('Users', 'User profile endpoints')
    .build();

  SwaggerModule.setup(
    SWAGGER_DOCS_PATH,
    app,
    SwaggerModule.createDocument(app, config),
  );
}

function printStartupBanner(port: number | string): void {
  console.log(`
╔════════════════════════════════════════╗
║   LoneWalker Backend - Started!        ║
╠════════════════════════════════════════╣
║  Server: http://localhost:${port}
║  API Docs: http://localhost:${port}/${SWAGGER_DOCS_PATH}
║  Environment: ${process.env.NODE_ENV}
╚════════════════════════════════════════╝
  `);
}

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  configureMiddleware(app);
  configureValidation(app);
  configureSwagger(app);
  const port = process.env.PORT ?? DEFAULT_APP_PORT;
  await app.listen(port);
  printStartupBanner(port);
}

bootstrap().catch(err => {
  console.error('Bootstrap error:', err);
  process.exit(1);
});
