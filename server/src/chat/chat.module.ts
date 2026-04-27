import { Module } from '@nestjs/common';

import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';
import { ChatAdminController } from './admin/chat-admin.controller';
import { ChatAdminService } from './admin/chat-admin.service';

@Module({
  controllers: [ChatController, ChatAdminController],
  providers: [ChatService, ChatAdminService],
})
export class ChatModule {}
