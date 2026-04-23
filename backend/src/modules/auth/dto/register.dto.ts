import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import {
  USERNAME_MIN_LENGTH,
  USERNAME_MAX_LENGTH,
  USERNAME_PATTERN,
  USERNAME_PATTERN_MESSAGE,
  PASSWORD_MIN_LENGTH,
  PASSWORD_COMPLEXITY_PATTERN,
  PASSWORD_COMPLEXITY_MESSAGE,
} from '../../../common/constants/validation.constants';

export class RegisterDto {
  @ApiProperty({
    example: 'explorador123',
    description: 'Username (alphanumeric and underscores)',
  })
  @IsString()
  @MinLength(USERNAME_MIN_LENGTH)
  @MaxLength(USERNAME_MAX_LENGTH)
  @Matches(USERNAME_PATTERN, { message: USERNAME_PATTERN_MESSAGE })
  username: string;

  @ApiProperty({
    example: 'user@example.com',
    description: 'User email address',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'SecurePass123!',
    description: 'Password (min 8 characters)',
  })
  @IsString()
  @MinLength(PASSWORD_MIN_LENGTH)
  @Matches(PASSWORD_COMPLEXITY_PATTERN, {
    message: PASSWORD_COMPLEXITY_MESSAGE,
  })
  password: string;

  @ApiProperty({
    example: 'SecurePass123!',
    description: 'Password confirmation',
  })
  @IsString()
  passwordConfirm: string;
}
