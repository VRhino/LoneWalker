import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Middleware
  app.use(helmet());
  app.enableCors({
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    credentials: process.env.CORS_CREDENTIALS === 'true',
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('LoneWalker API')
    .setDescription('GPS-based exploration gamification API')
    .setVersion('0.1.0')
    .addBearerAuth(
      { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      'jwt',
    )
    .addTag('Auth', 'Authentication endpoints')
    .addTag('Exploration', 'Map and exploration endpoints')
    .addTag('Treasures', 'Treasure hunt endpoints')
    .addTag('Landmarks', 'Community landmarks endpoints')
    .addTag('Ranking', 'User ranking endpoints')
    .addTag('Users', 'User profile endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);

  console.log(`
╔════════════════════════════════════════╗
║   LoneWalker Backend - Started! 🗺️      ║
╠════════════════════════════════════════╣
║  Server: http://localhost:${port}
║  API Docs: http://localhost:${port}/api/docs
║  Environment: ${process.env.NODE_ENV}
╚════════════════════════════════════════╝
  `);
}

bootstrap().catch((err) => {
  console.error('Bootstrap error:', err);
  process.exit(1);
});
