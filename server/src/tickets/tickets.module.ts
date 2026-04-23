import { Module } from '@nestjs/common';

import { NotificationsModule } from '../notifications/notifications.module';
import { TicketHistoryService } from './ticket-history.service';
import { TicketsController } from './tickets.controller';
import { TicketsService } from './tickets.service';

@Module({
  imports: [NotificationsModule],
  controllers: [TicketsController],
  providers: [TicketsService, TicketHistoryService],
  exports: [TicketHistoryService],
})
export class TicketsModule {}
