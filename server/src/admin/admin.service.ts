import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, TicketStatus } from '@prisma/client';

import { AuthenticatedUser } from '../auth/authenticated-user.interface';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
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

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async listFaqCategories(
    user: AuthenticatedUser,
    query: AdminListFaqCategoriesDto,
  ) {
    this.assertAgent(user);

    return this.prisma.faqCategory.findMany({
      where:
        query.isActive === undefined ? undefined : { isActive: query.isActive },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
  }

  async createFaqCategory(
    user: AuthenticatedUser,
    dto: CreateFaqCategoryDto,
  ) {
    this.assertAgent(user);

    return this.prisma.faqCategory.create({
      data: {
        name: dto.name.trim(),
        sortOrder: dto.sortOrder ?? 0,
        isActive: dto.isActive ?? true,
      },
    });
  }

  async updateFaqCategory(
    user: AuthenticatedUser,
    id: string,
    dto: UpdateFaqCategoryDto,
  ) {
    this.assertAgent(user);
    await this.ensureFaqCategoryExists(id);

    return this.prisma.faqCategory.update({
      where: { id },
      data: {
        ...(dto.name === undefined ? {} : { name: dto.name.trim() }),
        ...(dto.sortOrder === undefined ? {} : { sortOrder: dto.sortOrder }),
        ...(dto.isActive === undefined ? {} : { isActive: dto.isActive }),
      },
    });
  }

  async deactivateFaqCategory(user: AuthenticatedUser, id: string) {
    this.assertAgent(user);
    await this.ensureFaqCategoryExists(id);

    return this.prisma.faqCategory.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async listFaqs(user: AuthenticatedUser, query: AdminListFaqsDto) {
    this.assertAgent(user);

    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;
    const skip = (page - 1) * pageSize;
    const trimmedKeyword = query.keyword?.trim();
    const where: Prisma.FaqWhereInput = {
      ...(query.categoryId ? { categoryId: query.categoryId } : {}),
      ...(query.isActive === undefined ? {} : { isActive: query.isActive }),
      ...(trimmedKeyword
        ? {
            OR: [
              {
                question: {
                  contains: trimmedKeyword,
                  mode: 'insensitive',
                },
              },
              {
                answer: {
                  contains: trimmedKeyword,
                  mode: 'insensitive',
                },
              },
              {
                keywords: {
                  has: trimmedKeyword,
                },
              },
            ],
          }
        : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.faq.findMany({
        where,
        orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        skip,
        take: pageSize,
        include: {
          category: {
            select: {
              id: true,
              name: true,
              isActive: true,
              sortOrder: true,
            },
          },
        },
      }),
      this.prisma.faq.count({ where }),
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

  async getFaq(user: AuthenticatedUser, id: string) {
    this.assertAgent(user);

    const faq = await this.prisma.faq.findUnique({
      where: { id },
      include: {
        category: {
          select: {
            id: true,
            name: true,
            isActive: true,
            sortOrder: true,
          },
        },
      },
    });

    if (!faq) {
      throw new NotFoundException('FAQ not found');
    }

    return faq;
  }

  async createFaq(user: AuthenticatedUser, dto: CreateFaqDto) {
    this.assertAgent(user);
    await this.ensureFaqCategoryExists(dto.categoryId);

    return this.prisma.faq.create({
      data: {
        categoryId: dto.categoryId,
        question: dto.question.trim(),
        answer: dto.answer.trim(),
        keywords: this.normalizeKeywords(dto.keywords),
        sortOrder: dto.sortOrder ?? 0,
        isActive: dto.isActive ?? true,
      },
      include: {
        category: {
          select: {
            id: true,
            name: true,
            isActive: true,
            sortOrder: true,
          },
        },
      },
    });
  }

  async updateFaq(user: AuthenticatedUser, id: string, dto: UpdateFaqDto) {
    this.assertAgent(user);
    await this.ensureFaqExists(id);

    if (dto.categoryId) {
      await this.ensureFaqCategoryExists(dto.categoryId);
    }

    return this.prisma.faq.update({
      where: { id },
      data: {
        ...(dto.categoryId === undefined ? {} : { categoryId: dto.categoryId }),
        ...(dto.question === undefined ? {} : { question: dto.question.trim() }),
        ...(dto.answer === undefined ? {} : { answer: dto.answer.trim() }),
        ...(dto.keywords === undefined
          ? {}
          : { keywords: this.normalizeKeywords(dto.keywords) }),
        ...(dto.sortOrder === undefined ? {} : { sortOrder: dto.sortOrder }),
        ...(dto.isActive === undefined ? {} : { isActive: dto.isActive }),
      },
      include: {
        category: {
          select: {
            id: true,
            name: true,
            isActive: true,
            sortOrder: true,
          },
        },
      },
    });
  }

  async deactivateFaq(user: AuthenticatedUser, id: string) {
    this.assertAgent(user);
    await this.ensureFaqExists(id);

    return this.prisma.faq.update({
      where: { id },
      data: { isActive: false },
    });
  }

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
          assignedAgent: {
            select: {
              id: true,
              displayName: true,
              email: true,
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

  async getTicket(user: AuthenticatedUser, id: string) {
    this.assertAgent(user);

    const ticket = await this.prisma.ticket.findUnique({
      where: { id },
      select: {
        id: true,
        ticketNo: true,
        subject: true,
        description: true,
        category: true,
        status: true,
        priority: true,
        createdAt: true,
        updatedAt: true,
        resolvedAt: true,
        closedAt: true,
        user: {
          select: {
            id: true,
            displayName: true,
            email: true,
            phone: true,
          },
        },
        assignedAgent: {
          select: {
            id: true,
            displayName: true,
            email: true,
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
        messages: {
          where: { deletedAt: null },
          orderBy: { createdAt: 'asc' },
          select: {
            id: true,
            senderRole: true,
            type: true,
            body: true,
            isInternal: true,
            createdAt: true,
            sender: {
              select: {
                id: true,
                displayName: true,
                email: true,
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
              },
            },
          },
        },
      },
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    return ticket;
  }

  async assignTicket(user: AuthenticatedUser, id: string, dto: AssignTicketDto) {
    this.assertAgent(user);

    const ticket = await this.prisma.ticket.findUnique({
      where: { id },
      select: {
        id: true,
        ticketNo: true,
        userId: true,
        status: true,
      },
    });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }
    if (ticket.status === TicketStatus.CLOSED) {
      throw new BadRequestException('Closed tickets cannot be assigned');
    }

    const agent = await this.prisma.user.findUnique({
      where: { id: dto.agentId },
      select: { id: true, role: true, status: true },
    });
    if (!agent || (agent.role !== 'AGENT' && agent.role !== 'ADMIN')) {
      throw new BadRequestException('Assignee must be an agent or admin');
    }
    if (agent.status !== 'ACTIVE') {
      throw new BadRequestException('Assignee must be active');
    }

    const updatedTicket = await this.prisma.ticket.update({
      where: { id },
      data: {
        assignedAgentId: dto.agentId,
        status:
          ticket.status === TicketStatus.OPEN || ticket.status === TicketStatus.PENDING
            ? TicketStatus.IN_PROGRESS
            : ticket.status,
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
        status: true,
      },
    });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }
    if (ticket.status === TicketStatus.CLOSED) {
      throw new BadRequestException('Closed tickets cannot be replied to');
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

    if (dto.attachmentIds?.length) {
      await this.prisma.ticketAttachment.updateMany({
        where: {
          id: { in: dto.attachmentIds },
          uploaderId: user.id,
          ticketId: id,
          messageId: null,
        },
        data: { messageId: message.id },
      });
    }

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
        status: true,
      },
    });
    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    this.assertStatusTransition(ticket.status, dto.status);

    const now = new Date();
    const updatedTicket = await this.prisma.ticket.update({
      where: { id },
      data: {
        status: dto.status,
        resolvedAt: dto.status === TicketStatus.RESOLVED ? now : null,
        closedAt: dto.status === TicketStatus.CLOSED ? now : null,
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

  private async ensureFaqCategoryExists(id: string) {
    const category = await this.prisma.faqCategory.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!category) {
      throw new NotFoundException('FAQ category not found');
    }
  }

  private async ensureFaqExists(id: string) {
    const faq = await this.prisma.faq.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!faq) {
      throw new NotFoundException('FAQ not found');
    }
  }

  private normalizeKeywords(keywords: string[] | undefined) {
    return [...new Set((keywords ?? []).map((keyword) => keyword.trim()))].filter(
      Boolean,
    );
  }

  private assertStatusTransition(current: TicketStatus, next: TicketStatus) {
    if (current === next) {
      return;
    }

    const allowedTransitions: Record<TicketStatus, TicketStatus[]> = {
      [TicketStatus.OPEN]: [
        TicketStatus.PENDING,
        TicketStatus.IN_PROGRESS,
        TicketStatus.RESOLVED,
        TicketStatus.CLOSED,
      ],
      [TicketStatus.PENDING]: [
        TicketStatus.OPEN,
        TicketStatus.IN_PROGRESS,
        TicketStatus.RESOLVED,
        TicketStatus.CLOSED,
      ],
      [TicketStatus.IN_PROGRESS]: [
        TicketStatus.PENDING,
        TicketStatus.RESOLVED,
        TicketStatus.CLOSED,
      ],
      [TicketStatus.RESOLVED]: [TicketStatus.IN_PROGRESS, TicketStatus.CLOSED],
      [TicketStatus.CLOSED]: [],
    };

    if (!allowedTransitions[current].includes(next)) {
      throw new BadRequestException(
        `Ticket status cannot change from ${current} to ${next}`,
      );
    }
  }

  private assertAgent(user: AuthenticatedUser) {
    if (user.role !== 'AGENT' && user.role !== 'ADMIN') {
      throw new ForbiddenException('Agent access required');
    }
  }
}
