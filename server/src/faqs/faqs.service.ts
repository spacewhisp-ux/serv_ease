import { Injectable } from '@nestjs/common';

import { ListFaqsDto } from './dto/list-faqs.dto';

@Injectable()
export class FaqsService {
  listCategories() {
    return [
      {
        id: 'placeholder-category-id',
        name: 'Getting Started',
        sortOrder: 1,
      },
    ];
  }

  listFaqs(query: ListFaqsDto) {
    return {
      items: [
        {
          id: 'placeholder-faq-id',
          categoryId: query.categoryId ?? 'placeholder-category-id',
          question: 'How do I create a support ticket?',
          answerPreview: 'Go to the Tickets tab and submit your issue.',
          viewCount: 0,
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

  getFaq(id: string) {
    return {
      id,
      categoryId: 'placeholder-category-id',
      question: 'How do I create a support ticket?',
      answer: 'Go to the Tickets tab, tap create, and describe your issue.',
      keywords: ['ticket', 'support'],
    };
  }
}
