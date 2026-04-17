import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/session/session_cubit.dart';
import '../../../core/widgets/primary_pill_button.dart';
import '../../../core/widgets/surface_card.dart';
import 'login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _submit(LoginState state) {
    final account = _accountController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();

    String? message;
    if (account.isEmpty) {
      message = 'Enter your email or phone number.';
    } else if (password.length < 8) {
      message = 'Password must be at least 8 characters.';
    } else if (state.isRegistering && displayName.length < 2) {
      message = 'Display name must be at least 2 characters.';
    } else if (state.isRegistering && !account.contains('@')) {
      final phonePattern = RegExp(r'^\+?[0-9]{8,15}$');
      if (!phonePattern.hasMatch(account)) {
        message = 'Use a valid email or phone number in international format.';
      }
    }

    setState(() => _validationMessage = message);
    if (message != null) {
      return;
    }

    context.read<LoginCubit>().submit(
      account: account,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state.status == LoginStatus.success && state.user != null) {
          if (mounted) {
            setState(() => _validationMessage = null);
          }
          await context.read<SessionCubit>().setAuthenticated(state.user!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer care, simplified.',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.isRegistering
                              ? 'Create your account to search answers, submit tickets, and track support updates.'
                              : 'Sign in to access FAQs, tickets, and notifications from your support workspace.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        if (state.isRegistering) ...[
                          TextField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Display name',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: _accountController,
                          decoration: const InputDecoration(
                            labelText: 'Email or phone',
                            hintText: 'name@example.com or +8613812345678',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_validationMessage != null ||
                            state.errorMessage != null) ...[
                          Text(
                            _validationMessage ?? state.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryPillButton(
                            label: state.isRegistering
                                ? 'Create account'
                                : 'Sign in',
                            isLoading: state.status == LoginStatus.submitting,
                            onPressed: () => _submit(state),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() => _validationMessage = null);
                            context.read<LoginCubit>().toggleMode();
                          },
                          child: Text(
                            state.isRegistering
                                ? 'Already have an account? Sign in'
                                : 'Need an account? Create one',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
