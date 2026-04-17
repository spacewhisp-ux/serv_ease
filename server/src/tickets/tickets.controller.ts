import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';

import { TicketsService } from './tickets.service';
import { CloseTicketDto } from './dto/close-ticket.dto';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { ListTicketsDto } from './dto/list-tickets.dto';
import { ReplyTicketDto } from './dto/reply-ticket.dto';

@Controller('tickets')
export class TicketsController {
  constructor(private readonly ticketsService: TicketsService) {}

  @Post()
  createTicket(@Body() dto: CreateTicketDto) {
    return this.ticketsService.createTicket(dto);
  }

  @Get()
  listTickets(@Query() query: ListTicketsDto) {
    return this.ticketsService.listTickets(query);
  }

  @Get(':id')
  getTicket(@Param('id') id: string) {
    return this.ticketsService.getTicket(id);
  }

  @Post(':id/messages')
  replyTicket(@Param('id') id: string, @Body() dto: ReplyTicketDto) {
    return this.ticketsService.replyTicket(id, dto);
  }

  @Patch(':id/close')
  closeTicket(@Param('id') id: string, @Body() dto: CloseTicketDto) {
    return this.ticketsService.closeTicket(id, dto);
  }
}
