import { IsString, IsOptional, IsBoolean, IsInt, MaxLength, MinLength } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateChatQuestionDto {
  @IsString()
  @MinLength(1)
  @MaxLength(255)
  text!: string;

  @IsString()
  @MinLength(1)
  reply!: string;

  @IsOptional()
  @IsString()
  linkUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  linkLabel?: string;

  @IsOptional()
  @IsInt()
  sortOrder?: number;

  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true' || value === true) return true;
    if (value === 'false' || value === false) return false;
    return value;
  })
  @IsBoolean()
  isActive?: boolean;
}
