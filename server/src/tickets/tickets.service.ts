import { Injectable, NotFoundException } from '@nestjs/common';
import { TicketStatus } from '@prisma/client';

import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { CloseTicketDto } from './dto/close-ticket.dto';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { ListTicketsDto } from './dto/list-tickets.dto';
import { ReplyTicketDto } from './dto/reply-ticket.dto';

@Injectable()
export class TicketsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async createTicket(userId: string, dto: CreateTicketDto) {
    const now = new Date();
    const ticketNo = await this.generateTicketNo(now);

    const ticket = await this.prisma.ticket.create({
      data: {
        ticketNo,
        userId,
        subject: dto.subject,
        description: dto.description,
        category: dto.category,
        priority: dto.priority ?? 'NORMAL',
        status: TicketStatus.OPEN,
        lastMessageAt: now,
        messages: {
          create: {
            senderId: userId,
            senderRole: 'USER',
            type: 'TEXT',
            body: dto.description,
          },
        },
      },
      select: {
        id: true,
        ticketNo: true,
        status: true,
        subject: true,
        createdAt: true,
      },
    });

    if (dto.attachmentIds?.length) {
      await this.prisma.ticketAttachment.updateMany({
        where: {
          id: { in: dto.attachmentIds },
          uploaderId: userId,
          messageId: null,
        },
        data: { ticketId: ticket.id },
      });
    }

    return ticket;
  }

  async listTickets(userId: string, query: ListTicketsDto) {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;
    const skip = (page - 1) * pageSize;
    const where = {
      userId,
      ...(query.status ? { status: query.status } : {}),
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
          status: true,
          priority: true,
          updatedAt: true,
          lastMessageAt: true,
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

  async getTicket(userId: string, id: string) {
    const ticket = await this.prisma.ticket.findFirst({
      where: { id, userId },
      select: {
        id: true,
        ticketNo: true,
        subject: true,
        description: true,
        status: true,
        priority: true,
        category: true,
        createdAt: true,
        updatedAt: true,
        messages: {
          where: { deletedAt: null, isInternal: false },
          orderBy: { createdAt: 'asc' },
          select: {
            id: true,
            senderRole: true,
            type: true,
            body: true,
            createdAt: true,
            attachments: {
              where: { status: 'ACTIVE' },
              orderBy: { createdAt: 'asc' },
              select: {
                id: true,
                fileName: true,
                mimeType: true,
                fileSize: true,
                createdAt: true,
              },
            },
          },
        },
        attachments: {
          where: { status: 'ACTIVE' },
          orderBy: { createdAt: 'asc' },
          select: {
            id: true,
            fileName: true,
            mimeType: true,
            fileSize: true,
            createdAt: true,
            messageId: true,
          },
        },
      },
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    return ticket;
  }

  async replyTicket(userId: string, id: string, dto: ReplyTicketDto) {
    const ticket = await this.prisma.ticket.findFirst({
      where: { id, userId },
      select: {
        id: true,
        status: true,
        ticketNo: true,
        assignedAgentId: true,
      },
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    const message = await this.prisma.ticketMessage.create({
      data: {
        ticketId: id,
        senderId: userId,
        senderRole: 'USER',
        type: 'TEXT',
        body: dto.body,
      },
      select: {
        id: true,
        ticketId: true,
        body: true,
        createdAt: true,
      },
    });

    const now = new Date();
    await this.prisma.ticket.update({
      where: { id },
      data: {
        status: ticket.status === TicketStatus.CLOSED ? TicketStatus.OPEN : ticket.status,
        lastMessageAt: now,
      },
    });

    if (dto.attachmentIds?.length) {
      await this.prisma.ticketAttachment.updateMany({
        where: {
          id: { in: dto.attachmentIds },
          uploaderId: userId,
          ticketId: id,
          messageId: null,
        },
        data: { messageId: message.id },
      });
    }

    if (ticket.assignedAgentId) {
      await this.notificationsService.createNotification({
        userId: ticket.assignedAgentId,
        type: 'TICKET_UPDATED',
        title: 'Ticket updated',
        body: `User replied to ${ticket.ticketNo}.`,
        data: { ticketId: id, ticketNo: ticket.ticketNo },
      });
    }

    return {
      messageId: message.id,
      ticketId: message.ticketId,
      body: message.body,
      attachmentIds: dto.attachmentIds ?? [],
      createdAt: message.createdAt,
    };
  }

  async closeTicket(userId: string, id: string, dto: CloseTicketDto) {
    const ticket = await this.prisma.ticket.findFirst({
      where: { id, userId },
      select: {
        id: true,
        ticketNo: true,
        assignedAgentId: true,
      },
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    const closedTicket = await this.prisma.ticket.update({
      where: { id },
      data: {
        status: TicketStatus.CLOSED,
        closedAt: new Date(),
        lastMessageAt: new Date(),
        messages: dto.reason
          ? {
              create: {
                senderRole: 'SYSTEM',
                type: 'SYSTEM',
                body: dto.reason,
              },
            }
          : undefined,
      },
      select: {
        id: true,
        status: true,
        closedAt: true,
      },
    });

    if (ticket.assignedAgentId) {
      await this.notificationsService.createNotification({
        userId: ticket.assignedAgentId,
        type: 'TICKET_UPDATED',
        title: 'Ticket closed',
        body: `User closed ${ticket.ticketNo}.`,
        data: { ticketId: id, ticketNo: ticket.ticketNo },
      });
    }

    return {
      ...closedTicket,
      reason: dto.reason ?? null,
    };
  }

  private async generateTicketNo(now: Date) {
    const date = now.toISOString().slice(0, 10).replaceAll('-', '');
    const count = await this.prisma.ticket.count({
      where: {
        createdAt: {
          gte: new Date(`${now.toISOString().slice(0, 10)}T00:00:00.000Z`),
        },
      },
    });

    return `SE-${date}-${String(count + 1).padStart(4, '0')}`;
  }
}
