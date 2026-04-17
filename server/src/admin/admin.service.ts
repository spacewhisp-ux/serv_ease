import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { TicketStatus } from '@prisma/client';

import { AuthenticatedUser } from '../auth/authenticated-user.interface';
import { PrismaService } from '../prisma/prisma.service';
import { AdminListTicketsDto } from './dto/admin-list-tickets.dto';
import { AdminReplyTicketDto } from './dto/admin-reply-ticket.dto';
import { AssignTicketDto } from './dto/assign-ticket.dto';
import { UpdateAdminTicketStatusDto } from './dto/update-admin-ticket-status.dto';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

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

    const ticket = await this.prisma.ticket.findUnique({ where: { id } });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    return this.prisma.ticket.update({
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
  }

  async replyTicket(user: AuthenticatedUser, id: string, dto: AdminReplyTicketDto) {
    this.assertAgent(user);

    const ticket = await this.prisma.ticket.findUnique({ where: { id } });
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

    return message;
  }

  async updateTicketStatus(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateAdminTicketStatusDto,
  ) {
    this.assertAgent(user);

    const ticket = await this.prisma.ticket.findUnique({ where: { id } });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    return this.prisma.ticket.update({
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
  }

  private assertAgent(user: AuthenticatedUser) {
    if (user.role !== 'AGENT' && user.role !== 'ADMIN') {
      throw new ForbiddenException('Agent access required');
    }
  }
}
