import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/app_localizations_x.dart';
import '../core/session/session_cubit.dart';
import '../features/admin_faqs/presentation/admin_faq_management_screen.dart';
import '../features/faqs/presentation/faq_list_screen.dart';
import '../features/notifications/presentation/notifications_cubit.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tickets/presentation/ticket_list_screen.dart';
import 'app_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = context.select<SessionCubit, String?>(
      (cubit) => cubit.state.user?['role'] as String?,
    );
    final canManageFaqs = role == 'AGENT' || role == 'ADMIN';
    final titles = [l10n.navFaqs, l10n.navTickets, l10n.navAlerts];
    final unreadCount = context.select<NotificationsCubit, int>(
      (cubit) => cubit.state.unreadCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          PopupMenuButton<String>(
            color: AppTheme.pureWhite,
            onSelected: (value) {
              if (value == 'adminFaqs') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminFaqManagementScreen(),
                  ),
                );
                return;
              }

              if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                return;
              }

              if (value == 'logout') {
                context.read<SessionCubit>().logout();
              }
            },
            itemBuilder: (context) => [
              if (canManageFaqs)
                const PopupMenuItem<String>(
                  value: 'adminFaqs',
                  child: Text('FAQ management'),
                ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text(context.l10n.menuSettings),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text(context.l10n.menuSignOut),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            FaqListScreen(),
            TicketListScreen(),
            NotificationsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.pureWhite,
        indicatorColor: AppTheme.cloudGray,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 2) {
            context.read<NotificationsCubit>().load();
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: l10n.navFaqs,
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: l10n.navTickets,
          ),
          NavigationDestination(
            icon: _NotificationIcon(unreadCount: unreadCount),
            selectedIcon: _NotificationIcon(
              unreadCount: unreadCount,
              filled: true,
            ),
            label: l10n.navAlerts,
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.unreadCount, this.filled = false});

  final int unreadCount;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final icon = filled ? Icons.notifications : Icons.notifications_outlined;
    if (unreadCount <= 0) {
      return Icon(icon);
    }

    return Badge(
      label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
      child: Icon(icon),
    );
  }
}
