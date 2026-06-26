import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_shell.dart';
import '../providers/auth_controller.dart';
import 'sign_in_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, this.authenticatedChild});

  final Widget? authenticatedChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return authState.when(
      data: (state) {
        if (state.status == AuthStatus.authenticated) {
          return authenticatedChild ?? const FlowFiAppShell();
        }
        return const SignInScreen();
      },
      error: (error, stackTrace) => const SignInScreen(
        initialMessage: 'Session expired. Please login again.',
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
