import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const FALLBACK_REPLY =
  '抱歉，我暂时无法解答这个问题。您可以提交工单，我们的客服团队会尽快为您处理。';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async listQuestions() {
    return this.prisma.chatQuestion.findMany({
      where: { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
      select: {
        id: true,
        text: true,
        reply: true,
        linkUrl: true,
        linkLabel: true,
        sortOrder: true,
      },
    });
  }

  async matchKeyword(text: string) {
    const normalized = text.trim().toLowerCase();

    const keywords = await this.prisma.chatKeyword.findMany({
      where: { isActive: true },
      orderBy: [
        { keyword: 'desc' }, // longer keywords first for specificity
      ],
    });

    for (const kw of keywords) {
      if (normalized.includes(kw.keyword.toLowerCase())) {
        return {
          matched: true,
          reply: kw.reply,
          keyword: kw.keyword,
          suggestTicket: false,
        };
      }
    }

    return {
      matched: false,
      reply: FALLBACK_REPLY,
      keyword: undefined,
      suggestTicket: true,
    };
  }
}
