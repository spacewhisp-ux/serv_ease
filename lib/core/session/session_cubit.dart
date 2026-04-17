import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/auth_repository.dart';
import 'session_store.dart';

enum SessionStatus { loading, unauthenticated, authenticated }

class SessionState extends Equatable {
  const SessionState({required this.status, this.user});

  const SessionState.loading() : this(status: SessionStatus.loading);
  const SessionState.unauthenticated()
    : this(status: SessionStatus.unauthenticated);
  const SessionState.authenticated(Map<String, dynamic> user)
    : this(status: SessionStatus.authenticated, user: user);

  final SessionStatus status;
  final Map<String, dynamic>? user;

  @override
  List<Object?> get props => [status, user];
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required AuthRepository authRepository,
    required SessionStore sessionStore,
  }) : _authRepository = authRepository,
       _sessionStore = sessionStore,
       super(const SessionState.loading());

  final AuthRepository _authRepository;
  final SessionStore _sessionStore;

  Future<void> restoreSession() async {
    emit(const SessionState.loading());
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      emit(const SessionState.unauthenticated());
      return;
    }

    try {
      final user = await _authRepository.fetchCurrentUser();
      await _sessionStore.updateUser(user);
      emit(SessionState.authenticated(user));
    } catch (_) {
      await _authRepository.clearSession();
      emit(const SessionState.unauthenticated());
    }
  }

  Future<void> setAuthenticated(Map<String, dynamic> user) async {
    await _sessionStore.updateUser(user);
    emit(SessionState.authenticated(user));
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const SessionState.unauthenticated());
  }
}
