import { IsEnum, IsOptional, IsUUID } from 'class-validator';

import { PaginationDto } from '../../common/dto/pagination.dto';
import { TicketStatus } from '../../common/enums/ticket-status.enum';

export class AdminListTicketsDto extends PaginationDto {
  @IsOptional()
  @IsEnum(TicketStatus)
  status?: TicketStatus;

  @IsOptional()
  @IsUUID()
  assignedAgentId?: string;
}
