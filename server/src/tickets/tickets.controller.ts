import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../auth/authenticated-user.interface';
import { CurrentUser } from '../common/current-user.decorator';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { TicketsService } from './tickets.service';
import { CloseTicketDto } from './dto/close-ticket.dto';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { ListTicketsDto } from './dto/list-tickets.dto';
import { ReplyTicketDto } from './dto/reply-ticket.dto';

@Controller('tickets')
@UseGuards(JwtAuthGuard)
export class TicketsController {
  constructor(private readonly ticketsService: TicketsService) {}

  @Post()
  createTicket(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateTicketDto,
  ) {
    return this.ticketsService.createTicket(user.id, dto);
  }

  @Get()
  listTickets(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: ListTicketsDto,
  ) {
    return this.ticketsService.listTickets(user.id, query);
  }

  @Get(':id')
  getTicket(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.ticketsService.getTicket(user.id, id);
  }

  @Post(':id/messages')
  replyTicket(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: ReplyTicketDto,
  ) {
    return this.ticketsService.replyTicket(user.id, id, dto);
  }

  @Patch(':id/close')
  closeTicket(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: CloseTicketDto,
  ) {
    return this.ticketsService.closeTicket(user.id, id, dto);
  }
}
