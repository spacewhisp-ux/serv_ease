import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { TicketStatus } from '@prisma/client';

import { AuthenticatedUser } from '../auth/authenticated-user.interface';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { AdminListTicketsDto } from './dto/admin-list-tickets.dto';
import { AdminReplyTicketDto } from './dto/admin-reply-ticket.dto';
import { AssignTicketDto } from './dto/assign-ticket.dto';
import { UpdateAdminTicketStatusDto } from './dto/update-admin-ticket-status.dto';

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async listTickets(user: AuthenticatedUser, query: AdminListTicketsDto) {
    this.assertAgent(user);

    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;
    const skip = (page - 1) * pageSize;
    const where = {
      ...(query.status ? { status: query.status } : {}),
      ...(query.assignedAgentId ? { assignedAgentId: query.assignedAgentId } : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.ticket.findMany({
        where,
        orderBy: [{ lastMessageAt: 'desc' }, { createdAt: 'desc' }],
        skip,
        take: pageSize,
        select: {
          id: true,
          ticketNo: true,
          subject: true,
          category: true,
          status: true,
          priority: true,
          assignedAgentId: true,
          createdAt: true,
          updatedAt: true,
          user: {
            select: {
              id: true,
              displayName: true,
              email: true,
              phone: true,
            },
          },
        },
      }),
      this.prisma.ticket.count({ where }),
    ]);

    return {
      items,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async assignTicket(user: AuthenticatedUser, id: string, dto: AssignTicketDto) {
    this.assertAgent(user);

    const ticket = await this.prisma.ticket.findUnique({
      where: { id },
      select: {
        id: true,
        ticketNo: true,
        userId: true,
      },
    });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    const updatedTicket = await this.prisma.ticket.update({
      where: { id },
      data: {
        assignedAgentId: dto.agentId,
        status: TicketStatus.IN_PROGRESS,
      },
      select: {
        id: true,
        assignedAgentId: true,
        status: true,
        updatedAt: true,
      },
    });

    await this.notificationsService.createNotification({
      userId: ticket.userId,
      type: 'TICKET_UPDATED',
      title: 'Ticket assigned',
      body: `Your ticket ${ticket.ticketNo} is now being handled.`,
      data: { ticketId: id, ticketNo: ticket.ticketNo },
    });

    return updatedTicket;
  }

  async replyTicket(user: AuthenticatedUser, id: string, dto: AdminReplyTicketDto) {
    this.assertAgent(user);

    const ticket = await this.prisma.ticket.findUnique({
      where: { id },
      select: {
        id: true,
        ticketNo: true,
        userId: true,
        assignedAgentId: true,
      },
    });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    const message = await this.prisma.ticketMessage.create({
      data: {
        ticketId: id,
        senderId: user.id,
        senderRole: 'AGENT',
        type: 'TEXT',
        body: dto.body,
        isInternal: dto.isInternal ?? false,
      },
      select: {
        id: true,
        ticketId: true,
        body: true,
        createdAt: true,
      },
    });

    await this.prisma.ticket.update({
      where: { id },
      data: {
        status: TicketStatus.IN_PROGRESS,
        assignedAgentId: ticket.assignedAgentId ?? user.id,
        lastMessageAt: new Date(),
      },
    });

    if (!(dto.isInternal ?? false)) {
      await this.notificationsService.createNotification({
        userId: ticket.userId,
        type: 'AGENT_REPLIED',
        title: 'Support replied',
        body: `There is a new reply on ${ticket.ticketNo}.`,
        data: { ticketId: id, ticketNo: ticket.ticketNo },
      });
    }

    return message;
  }

  async updateTicketStatus(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateAdminTicketStatusDto,
  ) {
    this.assertAgent(user);

    const ticket = await this.prisma.ticket.findUnique({
      where: { id },
      select: {
        id: true,
        ticketNo: true,
        userId: true,
      },
    });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    const updatedTicket = await this.prisma.ticket.update({
      where: { id },
      data: {
        status: dto.status,
        resolvedAt: dto.status === TicketStatus.RESOLVED ? new Date() : null,
        closedAt: dto.status === TicketStatus.CLOSED ? new Date() : null,
      },
      select: {
        id: true,
        status: true,
        resolvedAt: true,
        closedAt: true,
        updatedAt: true,
      },
    });

    await this.notificationsService.createNotification({
      userId: ticket.userId,
      type: 'TICKET_UPDATED',
      title: 'Ticket status updated',
      body: `Your ticket ${ticket.ticketNo} is now ${dto.status}.`,
      data: { ticketId: id, ticketNo: ticket.ticketNo, status: dto.status },
    });

    return updatedTicket;
  }

  private assertAgent(user: AuthenticatedUser) {
    if (user.role !== 'AGENT' && user.role !== 'ADMIN') {
      throw new ForbiddenException('Agent access required');
    }
  }
}
