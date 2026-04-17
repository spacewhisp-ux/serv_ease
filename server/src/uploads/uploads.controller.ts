import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';

import { AuthenticatedUser } from '../auth/authenticated-user.interface';
import { CurrentUser } from '../common/current-user.decorator';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CompleteUploadDto } from './dto/complete-upload.dto';
import { CreateTicketAttachmentDto } from './dto/create-ticket-attachment.dto';
import { UploadsService } from './uploads.service';

@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class UploadsController {
  constructor(private readonly uploadsService: UploadsService) {}

  @Post('ticket-attachments')
  createTicketAttachment(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateTicketAttachmentDto,
  ) {
    return this.uploadsService.createTicketAttachment(user.id, dto);
  }

  @Post(':attachmentId/complete')
  completeUpload(
    @CurrentUser() user: AuthenticatedUser,
    @Param('attachmentId') attachmentId: string,
    @Body() dto: CompleteUploadDto,
  ) {
    return this.uploadsService.completeUpload(user.id, attachmentId, dto);
  }
}
