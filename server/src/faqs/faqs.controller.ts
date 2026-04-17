import { Controller, Get, Param, Query } from '@nestjs/common';

import { FaqsService } from './faqs.service';
import { ListFaqsDto } from './dto/list-faqs.dto';

@Controller()
export class FaqsController {
  constructor(private readonly faqsService: FaqsService) {}

  @Get('faq-categories')
  listCategories() {
    return this.faqsService.listCategories();
  }

  @Get('faqs')
  listFaqs(@Query() query: ListFaqsDto) {
    return this.faqsService.listFaqs(query);
  }

  @Get('faqs/:id')
  getFaq(@Param('id') id: string) {
    return this.faqsService.getFaq(id);
  }
}
