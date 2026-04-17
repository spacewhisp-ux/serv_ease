import { Type } from 'class-transformer';
import { ArrayMaxSize, IsArray, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class ReplyTicketDto {
  @IsString()
  @MinLength(1)
  body!: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(6)
  @IsUUID(undefined, { each: true })
  @Type(() => String)
  attachmentIds?: string[];
}
