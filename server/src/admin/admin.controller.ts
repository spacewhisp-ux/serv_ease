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
import { AdminService } from './admin.service';
import { AdminListTicketsDto } from './dto/admin-list-tickets.dto';
import { AdminReplyTicketDto } from './dto/admin-reply-ticket.dto';
import { AssignTicketDto } from './dto/assign-ticket.dto';
import { UpdateAdminTicketStatusDto } from './dto/update-admin-ticket-status.dto';

@Controller('admin')
@UseGuards(JwtAuthGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('tickets')
  listTickets(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: AdminListTicketsDto,
  ) {
    return this.adminService.listTickets(user, query);
  }

  @Patch('tickets/:id/assign')
  assignTicket(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: AssignTicketDto,
  ) {
    return this.adminService.assignTicket(user, id, dto);
  }

  @Post('tickets/:id/messages')
  replyTicket(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: AdminReplyTicketDto,
  ) {
    return this.adminService.replyTicket(user, id, dto);
  }

  @Patch('tickets/:id/status')
  updateTicketStatus(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateAdminTicketStatusDto,
  ) {
    return this.adminService.updateTicketStatus(user, id, dto);
  }
}
