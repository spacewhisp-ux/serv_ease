import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../auth/authenticated-user.interface';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateChatQuestionDto } from './dto/create-chat-question.dto';
import { UpdateChatQuestionDto } from './dto/update-chat-question.dto';
import { CreateChatKeywordDto } from './dto/create-chat-keyword.dto';
import { UpdateChatKeywordDto } from './dto/update-chat-keyword.dto';
import { ListChatQuestionsDto, ListChatKeywordsDto } from './dto/list-chat.dto';

@Injectable()
export class ChatAdminService {
  constructor(private readonly prisma: PrismaService) {}

  private assertAgent(user: AuthenticatedUser) {
    if (user.role !== 'AGENT' && user.role !== 'ADMIN') {
      throw new ForbiddenException('Agent access required');
    }
  }

  // --- Chat Questions ---

  async listQuestions(user: AuthenticatedUser, query: ListChatQuestionsDto) {
    this.assertAgent(user);

    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;
    const skip = (page - 1) * pageSize;

    const where: any = {};
    if (query.isActive !== undefined) {
      where.isActive = query.isActive;
    }

    const [items, total] = await Promise.all([
      this.prisma.chatQuestion.findMany({
        where,
        orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        skip,
        take: pageSize,
      }),
      this.prisma.chatQuestion.count({ where }),
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

  async getQuestion(user: AuthenticatedUser, id: string) {
    this.assertAgent(user);
    const question = await this.prisma.chatQuestion.findUnique({ where: { id } });
    if (!question) {
      throw new NotFoundException('Chat question not found');
    }
    return question;
  }

  async createQuestion(user: AuthenticatedUser, dto: CreateChatQuestionDto) {
    this.assertAgent(user);
    return this.prisma.chatQuestion.create({ data: dto });
  }

  async updateQuestion(user: AuthenticatedUser, id: string, dto: UpdateChatQuestionDto) {
    this.assertAgent(user);
    const question = await this.prisma.chatQuestion.findUnique({ where: { id } });
    if (!question) {
      throw new NotFoundException('Chat question not found');
    }
    return this.prisma.chatQuestion.update({ where: { id }, data: dto });
  }

  async deactivateQuestion(user: AuthenticatedUser, id: string) {
    this.assertAgent(user);
    const question = await this.prisma.chatQuestion.findUnique({ where: { id } });
    if (!question) {
      throw new NotFoundException('Chat question not found');
    }
    return this.prisma.chatQuestion.update({
      where: { id },
      data: { isActive: false },
    });
  }

  // --- Chat Keywords ---

  async listKeywords(user: AuthenticatedUser, query: ListChatKeywordsDto) {
    this.assertAgent(user);

    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;
    const skip = (page - 1) * pageSize;

    const where: any = {};
    if (query.isActive !== undefined) {
      where.isActive = query.isActive;
    }
    if (query.keyword) {
      where.keyword = { contains: query.keyword, mode: 'insensitive' };
    }

    const [items, total] = await Promise.all([
      this.prisma.chatKeyword.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }],
        skip,
        take: pageSize,
      }),
      this.prisma.chatKeyword.count({ where }),
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

  async createKeyword(user: AuthenticatedUser, dto: CreateChatKeywordDto) {
    this.assertAgent(user);
    return this.prisma.chatKeyword.create({ data: dto });
  }

  async updateKeyword(user: AuthenticatedUser, id: string, dto: UpdateChatKeywordDto) {
    this.assertAgent(user);
    const keyword = await this.prisma.chatKeyword.findUnique({ where: { id } });
    if (!keyword) {
      throw new NotFoundException('Chat keyword not found');
    }
    return this.prisma.chatKeyword.update({ where: { id }, data: dto });
  }

  async deactivateKeyword(user: AuthenticatedUser, id: string) {
    this.assertAgent(user);
    const keyword = await this.prisma.chatKeyword.findUnique({ where: { id } });
    if (!keyword) {
      throw new NotFoundException('Chat keyword not found');
    }
    return this.prisma.chatKeyword.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
