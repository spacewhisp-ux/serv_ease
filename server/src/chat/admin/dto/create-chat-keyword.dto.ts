import { IsString, IsOptional, IsBoolean, MaxLength, MinLength } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateChatKeywordDto {
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  keyword!: string;

  @IsString()
  @MinLength(1)
  reply!: string;

  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true' || value === true) return true;
    if (value === 'false' || value === false) return false;
    return value;
  })
  @IsBoolean()
  isActive?: boolean;
}
