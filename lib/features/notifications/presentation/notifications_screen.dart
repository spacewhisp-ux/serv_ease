import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/primary_pill_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../data/notifications_repository.dart';
import 'notifications_cubit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<NotificationsCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stay in the loop.',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Review support updates and mark messages as read.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (state.unreadCount > 0) ...[
                    const SizedBox(width: 16),
                    _UnreadBadge(count: state.unreadCount),
                  ],
                ],
              ),
              if (state.unreadCount > 0) ...[
                const SizedBox(height: 20),
                PrimaryPillButton(
                  label: 'Mark all as read',
                  onPressed: () =>
                      context.read<NotificationsCubit>().markAllAsRead(),
                ),
              ],
              const SizedBox(height: 20),
              if (state.status == NotificationsStatus.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.status == NotificationsStatus.failure)
                EmptyStateCard(
                  title: 'Could not load notifications',
                  description: state.errorMessage ?? 'Please try again.',
                )
              else if (state.items.isEmpty)
                const EmptyStateCard(
                  title: 'No notifications',
                  description: 'Ticket updates will appear here.',
                )
              else
                ...state.items.map(
                  (notification) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationCard(notification: notification),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, HH:mm');
    return SurfaceCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: notification.isRead
            ? null
            : () => context.read<NotificationsCubit>().markAsRead(
                notification.id,
              ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: notification.isRead
                    ? AppTheme.cloudGray
                    : AppTheme.expoBlack,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 12, height: 12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${notification.typeLabel} • ${formatter.format(notification.createdAt.toLocal())}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.expoBlack,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$count unread',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

extension on AppNotification {
  String get typeLabel {
    return type
        .toLowerCase()
        .split('_')
        .map((segment) => '${segment[0].toUpperCase()}${segment.substring(1)}')
        .join(' ');
  }
}
