import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './strategies/jwt.strategy';
import { TokenService } from './services/token.service';
import { UsersModule } from '../users/users.module';
import {
  JWT_ALGORITHM,
  JWT_DEFAULT_EXPIRATION_S,
  JWT_EXPIRATION_KEY,
  JWT_SECRET_KEY,
} from '../../common/constants/auth.constants';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.registerAsync({
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>(JWT_SECRET_KEY),
        signOptions: {
          expiresIn: configService.get<number>(
            JWT_EXPIRATION_KEY,
            JWT_DEFAULT_EXPIRATION_S,
          ),
          algorithm: JWT_ALGORITHM,
        },
      }),
      inject: [ConfigService],
    }),
  ],
  providers: [AuthService, TokenService, JwtStrategy],
  controllers: [AuthController],
  exports: [AuthService],
})
export class AuthModule {}
