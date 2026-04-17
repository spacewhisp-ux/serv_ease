import { IsOptional, IsString, IsUUID } from 'class-validator';

import { PaginationDto } from '../../common/dto/pagination.dto';

export class ListFaqsDto extends PaginationDto {
  @IsOptional()
  @IsUUID()
  categoryId?: string;

  @IsOptional()
  @IsString()
  keyword?: string;
}
