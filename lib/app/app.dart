import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/api_client.dart';
import '../core/session/session_cubit.dart';
import '../core/session/session_store.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_cubit.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/faqs/data/faq_repository.dart';
import '../features/faqs/presentation/faq_list_cubit.dart';
import '../features/notifications/data/notifications_repository.dart';
import '../features/notifications/presentation/notifications_cubit.dart';
import '../features/tickets/data/ticket_repository.dart';
import '../features/tickets/presentation/create_ticket_cubit.dart';
import '../features/tickets/presentation/ticket_list_cubit.dart';
import 'app_shell.dart';
import 'app_theme.dart';

class ServEaseApp extends StatefulWidget {
  const ServEaseApp({super.key});

  @override
  State<ServEaseApp> createState() => _ServEaseAppState();
}

class _ServEaseAppState extends State<ServEaseApp> {
  late final SessionStore _sessionStore;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final FaqRepository _faqRepository;
  late final TicketRepository _ticketRepository;
  late final NotificationsRepository _notificationsRepository;

  @override
  void initState() {
    super.initState();
    _sessionStore = SessionStore();
    _apiClient = ApiClient(sessionStore: _sessionStore);
    _authRepository = AuthRepository(
      apiClient: _apiClient,
      sessionStore: _sessionStore,
    );
    _faqRepository = FaqRepository(apiClient: _apiClient);
    _ticketRepository = TicketRepository(apiClient: _apiClient);
    _notificationsRepository = NotificationsRepository(apiClient: _apiClient);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SessionStore>.value(value: _sessionStore),
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<FaqRepository>.value(value: _faqRepository),
        RepositoryProvider<TicketRepository>.value(value: _ticketRepository),
        RepositoryProvider<NotificationsRepository>.value(
          value: _notificationsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SessionCubit(
              authRepository: _authRepository,
              sessionStore: _sessionStore,
            )..restoreSession(),
          ),
          BlocProvider(
            create: (_) => LoginCubit(authRepository: _authRepository),
          ),
          BlocProvider(
            create: (_) => FaqListCubit(faqRepository: _faqRepository),
          ),
          BlocProvider(
            create: (_) => TicketListCubit(ticketRepository: _ticketRepository),
          ),
          BlocProvider(
            create: (_) =>
                CreateTicketCubit(ticketRepository: _ticketRepository),
          ),
          BlocProvider(
            create: (_) => NotificationsCubit(
              notificationsRepository: _notificationsRepository,
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Serv Ease',
          theme: AppTheme.light(),
          home: BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              if (state.status == SessionStatus.loading) {
                return const _SplashView();
              }

              if (state.status == SessionStatus.authenticated) {
                return const AppShell();
              }

              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
