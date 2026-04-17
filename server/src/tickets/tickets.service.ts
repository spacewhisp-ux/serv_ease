import { Injectable } from '@nestjs/common';

import { CloseTicketDto } from './dto/close-ticket.dto';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { ListTicketsDto } from './dto/list-tickets.dto';
import { ReplyTicketDto } from './dto/reply-ticket.dto';

@Injectable()
export class TicketsService {
  createTicket(dto: CreateTicketDto) {
    return {
      id: 'placeholder-ticket-id',
      ticketNo: 'SE-20260417-0001',
      status: 'OPEN',
      subject: dto.subject,
      createdAt: new Date().toISOString(),
    };
  }

  listTickets(query: ListTicketsDto) {
    return {
      items: [
        {
          id: 'placeholder-ticket-id',
          ticketNo: 'SE-20260417-0001',
          subject: 'I need help with my order',
          status: query.status ?? 'OPEN',
          priority: 'NORMAL',
          updatedAt: new Date().toISOString(),
        },
      ],
      pagination: {
        page: query.page ?? 1,
        pageSize: query.pageSize ?? 20,
        total: 1,
        totalPages: 1,
      },
    };
  }

  getTicket(id: string) {
    return {
      id,
      ticketNo: 'SE-20260417-0001',
      subject: 'I need help with my order',
      description: 'The order status has not updated for three days.',
      status: 'OPEN',
      priority: 'NORMAL',
      messages: [
        {
          id: 'placeholder-message-id',
          senderRole: 'USER',
          type: 'TEXT',
          body: 'The order status has not updated for three days.',
          createdAt: new Date().toISOString(),
        },
      ],
      attachments: [],
    };
  }

  replyTicket(id: string, dto: ReplyTicketDto) {
    return {
      ticketId: id,
      messageId: 'placeholder-message-id',
      body: dto.body,
      attachmentIds: dto.attachmentIds ?? [],
      createdAt: new Date().toISOString(),
    };
  }

  closeTicket(id: string, dto: CloseTicketDto) {
    return {
      id,
      status: 'CLOSED',
      reason: dto.reason ?? null,
      closedAt: new Date().toISOString(),
    };
  }
}
