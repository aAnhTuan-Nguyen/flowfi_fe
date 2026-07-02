import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_shell.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
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
        initialMessage: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      ),
      loading: () => const Scaffold(
        body: Center(
          child: FlowFiInlineLoading(label: 'Đang kiểm tra phiên đăng nhập'),
        ),
      ),
    );
  }
}
