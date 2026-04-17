import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';

import { PrismaService } from '../prisma/prisma.service';
import { CompleteUploadDto } from './dto/complete-upload.dto';
import { CreateTicketAttachmentDto } from './dto/create-ticket-attachment.dto';

const ALLOWED_MIME_TYPES = new Set([
  'image/jpeg',
  'image/png',
  'image/heic',
  'application/pdf',
]);
const MAX_FILE_SIZE = 10 * 1024 * 1024;

@Injectable()
export class UploadsService {
  constructor(private readonly prisma: PrismaService) {}

  async createTicketAttachment(userId: string, dto: CreateTicketAttachmentDto) {
    this.validateFile(dto.mimeType, dto.fileSize);

    const extension = this.getFileExtension(dto.fileName);
    const fileKey = `tickets/temp/${userId}/${randomUUID()}${extension}`;

    const attachment = await this.prisma.ticketAttachment.create({
      data: {
        uploaderId: userId,
        fileKey,
        fileName: dto.fileName,
        mimeType: dto.mimeType,
        fileSize: dto.fileSize,
      },
      select: {
        id: true,
        fileKey: true,
        fileName: true,
        mimeType: true,
        fileSize: true,
        createdAt: true,
      },
    });

    return {
      attachmentId: attachment.id,
      uploadUrl: `https://upload.example.com/${attachment.fileKey}`,
      fileKey: attachment.fileKey,
      fileName: attachment.fileName,
      mimeType: attachment.mimeType,
      fileSize: attachment.fileSize,
      createdAt: attachment.createdAt,
    };
  }

  async completeUpload(
    userId: string,
    attachmentId: string,
    dto: CompleteUploadDto,
  ) {
    const attachment = await this.prisma.ticketAttachment.findFirst({
      where: {
        id: attachmentId,
        uploaderId: userId,
        deletedAt: null,
      },
      select: {
        id: true,
        fileKey: true,
        fileName: true,
        mimeType: true,
        fileSize: true,
      },
    });

    if (!attachment) {
      throw new NotFoundException('Attachment not found');
    }

    return {
      attachmentId: attachment.id,
      uploaded: true,
      fileKey: attachment.fileKey,
      fileName: attachment.fileName,
      mimeType: attachment.mimeType,
      fileSize: attachment.fileSize,
      checksum: dto.checksum ?? null,
    };
  }

  private validateFile(mimeType: string, fileSize: number) {
    if (!ALLOWED_MIME_TYPES.has(mimeType)) {
      throw new BadRequestException({
        code: 'UNSUPPORTED_FILE_TYPE',
        message: 'Unsupported file type',
      });
    }

    if (fileSize > MAX_FILE_SIZE) {
      throw new BadRequestException({
        code: 'FILE_TOO_LARGE',
        message: 'File exceeds size limit',
      });
    }
  }

  private getFileExtension(fileName: string) {
    const lastDotIndex = fileName.lastIndexOf('.');
    return lastDotIndex >= 0 ? fileName.slice(lastDotIndex) : '';
  }
}
