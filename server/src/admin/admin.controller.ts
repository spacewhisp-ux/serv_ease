import {
  Body,
  Controller,
  Delete,
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
import { AdminListFaqCategoriesDto } from './dto/admin-list-faq-categories.dto';
import { AdminListFaqsDto } from './dto/admin-list-faqs.dto';
import { AdminListTicketsDto } from './dto/admin-list-tickets.dto';
import { AdminReplyTicketDto } from './dto/admin-reply-ticket.dto';
import { AssignTicketDto } from './dto/assign-ticket.dto';
import { CreateFaqCategoryDto } from './dto/create-faq-category.dto';
import { CreateFaqDto } from './dto/create-faq.dto';
import { UpdateAdminTicketStatusDto } from './dto/update-admin-ticket-status.dto';
import { UpdateFaqCategoryDto } from './dto/update-faq-category.dto';
import { UpdateFaqDto } from './dto/update-faq.dto';

@Controller('admin')
@UseGuards(JwtAuthGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('faq-categories')
  listFaqCategories(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: AdminListFaqCategoriesDto,
  ) {
    return this.adminService.listFaqCategories(user, query);
  }

  @Post('faq-categories')
  createFaqCategory(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateFaqCategoryDto,
  ) {
    return this.adminService.createFaqCategory(user, dto);
  }

  @Patch('faq-categories/:id')
  updateFaqCategory(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateFaqCategoryDto,
  ) {
    return this.adminService.updateFaqCategory(user, id, dto);
  }

  @Delete('faq-categories/:id')
  deactivateFaqCategory(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.adminService.deactivateFaqCategory(user, id);
  }

  @Get('faqs')
  listFaqs(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: AdminListFaqsDto,
  ) {
    return this.adminService.listFaqs(user, query);
  }

  @Get('faqs/:id')
  getFaq(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.adminService.getFaq(user, id);
  }

  @Post('faqs')
  createFaq(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateFaqDto,
  ) {
    return this.adminService.createFaq(user, dto);
  }

  @Patch('faqs/:id')
  updateFaq(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateFaqDto,
  ) {
    return this.adminService.updateFaq(user, id, dto);
  }

  @Delete('faqs/:id')
  deactivateFaq(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.adminService.deactivateFaq(user, id);
  }

  @Get('tickets')
  listTickets(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: AdminListTicketsDto,
  ) {
    return this.adminService.listTickets(user, query);
  }

  @Get('tickets/:id')
  getTicket(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.adminService.getTicket(user, id);
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
