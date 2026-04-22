import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { ListFaqsDto } from './dto/list-faqs.dto';

@Injectable()
export class FaqsService {
  constructor(private readonly prisma: PrismaService) {}

  async listCategories() {
    return this.prisma.faqCategory.findMany({
      where: { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
      select: {
        id: true,
        name: true,
        sortOrder: true,
      },
    });
  }

  async listFaqs(query: ListFaqsDto) {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;
    const skip = (page - 1) * pageSize;

    const where = {
      isActive: true,
      category: {
        isActive: true,
      },
      ...(query.categoryId ? { categoryId: query.categoryId } : {}),
      ...(query.keyword
        ? {
            OR: [
              {
                question: {
                  contains: query.keyword,
                  mode: 'insensitive' as const,
                },
              },
              {
                answer: {
                  contains: query.keyword,
                  mode: 'insensitive' as const,
                },
              },
              {
                keywords: {
                  has: query.keyword,
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
        select: {
          id: true,
          categoryId: true,
          question: true,
          answer: true,
          viewCount: true,
        },
      }),
      this.prisma.faq.count({ where }),
    ]);

    return {
      items: items.map((item) => ({
        id: item.id,
        categoryId: item.categoryId,
        question: item.question,
        answerPreview:
          item.answer.length > 120 ? `${item.answer.slice(0, 117)}...` : item.answer,
        viewCount: item.viewCount,
      })),
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async getFaq(id: string) {
    const faq = await this.prisma.faq.findFirst({
      where: {
        id,
        isActive: true,
        category: {
          isActive: true,
        },
      },
      select: {
        id: true,
        categoryId: true,
        question: true,
        answer: true,
        keywords: true,
        viewCount: true,
      },
    });

    if (!faq) {
      throw new NotFoundException('FAQ not found');
    }

    await this.prisma.faq.update({
      where: { id },
      data: {
        viewCount: {
          increment: 1,
        },
      },
    });

    return {
      ...faq,
      viewCount: faq.viewCount + 1,
    };
  }
}
