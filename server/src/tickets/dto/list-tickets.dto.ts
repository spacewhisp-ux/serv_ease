import { IsEnum, IsOptional } from 'class-validator';

import { PaginationDto } from '../../common/dto/pagination.dto';
import { TicketStatus } from '../../common/enums/ticket-status.enum';

export class ListTicketsDto extends PaginationDto {
  @IsOptional()
  @IsEnum(TicketStatus)
  status?: TicketStatus;
}
