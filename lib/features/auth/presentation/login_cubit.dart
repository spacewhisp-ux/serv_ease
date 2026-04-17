import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';

enum LoginStatus { idle, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.idle,
    this.isRegistering = false,
    this.errorMessage,
    this.user,
  });

  final LoginStatus status;
  final bool isRegistering;
  final String? errorMessage;
  final Map<String, dynamic>? user;

  LoginState copyWith({
    LoginStatus? status,
    bool? isRegistering,
    String? errorMessage,
    Map<String, dynamic>? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      isRegistering: isRegistering ?? this.isRegistering,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, isRegistering, errorMessage, user];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const LoginState());

  final AuthRepository _authRepository;

  void toggleMode() {
    emit(
      state.copyWith(
        isRegistering: !state.isRegistering,
        status: LoginStatus.idle,
      ),
    );
  }

  Future<void> submit({
    required String account,
    required String password,
    String? displayName,
  }) async {
    emit(state.copyWith(status: LoginStatus.submitting));

    try {
      final user = state.isRegistering
          ? await _authRepository.register(
              email: account.contains('@') ? account : null,
              phone: account.contains('@') ? null : account,
              password: password,
              displayName: displayName?.trim().isNotEmpty == true
                  ? displayName!.trim()
                  : 'Serv Ease User',
            )
          : await _authRepository.login(account: account, password: password);
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } catch (error) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
