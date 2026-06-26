import 'package:flowfi_fe/app/app_shell.dart';
import 'package:flowfi_fe/features/auth/domain/entities/auth_user.dart';
import 'package:flowfi_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/bootstrap_auth_session_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flowfi_fe/features/auth/presentation/providers/auth_controller.dart';
import 'package:flowfi_fe/features/auth/presentation/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../providers/auth_controller_test.dart';

void main() {
  testWidgets('shows the sign in screen when unauthenticated', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(FlowFiAppShell), findsNothing);
  });

  testWidgets('shows the app shell when authenticated', (tester) async {
    await tester.pumpWidget(
      _app(
        FakeAuthRepository(
          bootstrappedUser: const AuthUser(
            id: 'user-1',
            email: 'alex@example.com',
            fullName: 'Alex Morgan',
            currencyCode: 'VND',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FlowFiAppShell), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });
}

Widget _app(AuthRepository repository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      bootstrapAuthSessionUseCaseProvider.overrideWithValue(
        BootstrapAuthSessionUseCase(repository),
      ),
      signInUseCaseProvider.overrideWithValue(SignInUseCase(repository)),
      signUpUseCaseProvider.overrideWithValue(SignUpUseCase(repository)),
      signOutUseCaseProvider.overrideWithValue(SignOutUseCase(repository)),
    ],
    child: const MaterialApp(home: AuthGate()),
  );
}
