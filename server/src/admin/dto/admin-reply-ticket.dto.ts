import { IsBoolean, IsOptional, IsString, MinLength } from 'class-validator';

export class AdminReplyTicketDto {
  @IsString()
  @MinLength(1)
  body!: string;

  @IsOptional()
  @IsBoolean()
  isInternal?: boolean;
}
