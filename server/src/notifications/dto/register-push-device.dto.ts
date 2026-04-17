import { IsIn, IsOptional, IsString, MinLength } from 'class-validator';

export class RegisterPushDeviceDto {
  @IsString()
  @IsIn(['ios', 'android'])
  platform!: string;

  @IsString()
  @MinLength(16)
  pushToken!: string;

  @IsOptional()
  @IsString()
  deviceId?: string;
}
