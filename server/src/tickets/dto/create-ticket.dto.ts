import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

import { TicketPriority } from '../../common/enums/ticket-priority.enum';

export class CreateTicketDto {
  @IsString()
  @MinLength(5)
  @MaxLength(255)
  subject!: string;

  @IsString()
  @MinLength(10)
  description!: string;

  @IsString()
  @MaxLength(80)
  category!: string;

  @IsOptional()
  @IsEnum(TicketPriority)
  priority?: TicketPriority;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(6)
  @IsUUID(undefined, { each: true })
  @Type(() => String)
  attachmentIds?: string[];
}
