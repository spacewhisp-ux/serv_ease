import { Injectable, NotFoundException } from '@nestjs/common';
import type { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ListNotificationsDto } from './dto/list-notifications.dto';
import { RegisterPushDeviceDto } from './dto/register-push-device.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async listNotifications(userId: string, query: ListNotificationsDto) {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;
    const skip = (page - 1) * pageSize;

    const [items, total] = await Promise.all([
      this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: pageSize,
        select: {
          id: true,
          type: true,
          title: true,
          body: true,
          data: true,
          readAt: true,
          createdAt: true,
        },
      }),
      this.prisma.notification.count({ where: { userId } }),
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

  async getUnreadCount(userId: string) {
    const unreadCount = await this.prisma.notification.count({
      where: {
        userId,
        readAt: null,
      },
    });

    return { unreadCount };
  }

  async markAsRead(userId: string, id: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id, userId },
      select: { id: true, readAt: true },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    return this.prisma.notification.update({
      where: { id },
      data: {
        readAt: notification.readAt ?? new Date(),
      },
      select: {
        id: true,
        readAt: true,
      },
    });
  }

  async markAllAsRead(userId: string) {
    const updated = await this.prisma.notification.updateMany({
      where: {
        userId,
        readAt: null,
      },
      data: {
        readAt: new Date(),
      },
    });

    return { updatedCount: updated.count };
  }

  async registerPushDevice(userId: string, dto: RegisterPushDeviceDto) {
    const device = await this.prisma.pushDevice.upsert({
      where: {
        pushToken: dto.pushToken,
      },
      update: {
        userId,
        platform: dto.platform,
        deviceId: dto.deviceId,
        isActive: true,
      },
      create: {
        userId,
        platform: dto.platform,
        pushToken: dto.pushToken,
        deviceId: dto.deviceId,
        isActive: true,
      },
      select: {
        id: true,
        platform: true,
        pushToken: true,
        deviceId: true,
        isActive: true,
        updatedAt: true,
      },
    });

    return device;
  }

  async createNotification(input: CreateNotificationInput) {
    return this.prisma.notification.create({
      data: {
        userId: input.userId,
        type: input.type,
        title: input.title,
        body: input.body,
        data: input.data ?? undefined,
      },
      select: {
        id: true,
        userId: true,
        type: true,
        title: true,
        body: true,
        data: true,
        createdAt: true,
      },
    });
  }
}

interface CreateNotificationInput {
  userId: string;
  type: 'TICKET_UPDATED' | 'AGENT_REPLIED' | 'SYSTEM';
  title: string;
  body: string;
  data?: Prisma.InputJsonValue;
}
