import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notifications_repository.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;
  final int unreadCount;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, unreadCount, errorMessage];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required NotificationsRepository notificationsRepository})
    : _notificationsRepository = notificationsRepository,
      super(const NotificationsState());

  final NotificationsRepository _notificationsRepository;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    try {
      final results = await Future.wait([
        _notificationsRepository.fetchNotifications(),
        _notificationsRepository.fetchUnreadCount(),
      ]);
      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          items: (results[0] as NotificationsResult).items,
          unreadCount: results[1] as int,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> markAsRead(String id) async {
    await _notificationsRepository.markAsRead(id);
    await load();
  }

  Future<void> markAllAsRead() async {
    await _notificationsRepository.markAllAsRead();
    await load();
  }
}
