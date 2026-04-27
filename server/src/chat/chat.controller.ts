import { Body, Controller, Get, Post } from '@nestjs/common';

import { ChatService } from './chat.service';
import { SubmitChatDto } from './dto/submit-chat.dto';

@Controller()
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('chat/questions')
  listQuestions() {
    return this.chatService.listQuestions();
  }

  @Post('chat/submit')
  submitText(@Body() dto: SubmitChatDto) {
    return this.chatService.matchKeyword(dto.text);
  }
}
