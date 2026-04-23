import { Injectable } from '@nestjs/common';
import { TicketHistoryAction, TicketHistoryActorRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

interface CreateHistoryParams {
  ticketId: string;
  action: TicketHistoryAction;
  actorId?: string;
  actorRole: TicketHistoryActorRole;
  oldValue?: string;
  newValue?: string;
  metadata?: Record<string, any>;
}

@Injectable()
export class TicketHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  async createHistory(params: CreateHistoryParams) {
    return this.prisma.ticketHistory.create({
      data: {
        ticketId: params.ticketId,
        action: params.action,
        actorId: params.actorId,
        actorRole: params.actorRole,
        oldValue: params.oldValue,
        newValue: params.newValue,
        metadata: params.metadata,
      },
      select: {
        id: true,
        action: true,
        actorRole: true,
        oldValue: true,
        newValue: true,
        metadata: true,
        createdAt: true,
        actor: {
          select: {
            id: true,
            displayName: true,
            email: true,
            role: true,
          },
        },
      },
    });
  }

  async getTicketHistory(ticketId: string) {
    return this.prisma.ticketHistory.findMany({
      where: { ticketId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        action: true,
        actorRole: true,
        oldValue: true,
        newValue: true,
        metadata: true,
        createdAt: true,
        actor: {
          select: {
            id: true,
            displayName: true,
            email: true,
            role: true,
          },
        },
      },
    });
  }
}
