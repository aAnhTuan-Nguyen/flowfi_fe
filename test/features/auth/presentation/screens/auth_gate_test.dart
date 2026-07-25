import 'dart:async';

import 'package:flowfi_fe/features/auth/domain/entities/auth_user.dart';
import 'package:flowfi_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/bootstrap_auth_session_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flowfi_fe/features/auth/presentation/providers/auth_controller.dart';
import 'package:flowfi_fe/features/auth/presentation/screens/auth_gate.dart';
import 'package:flowfi_fe/features/shared/presentation/widgets/forui_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../providers/auth_controller_test.dart';

void main() {
  testWidgets('shows the sign in screen when unauthenticated', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.byKey(const Key('authenticated')), findsNothing);
  });

  testWidgets('returns from sign up to the sign in screen', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pumpAndSettle();

    expect(find.text('Tạo tài khoản'), findsWidgets);
    expect(find.text('Quay lại đăng nhập'), findsOneWidget);

    await tester.ensureVisible(find.text('Quay lại đăng nhập'));
    await tester.tap(find.text('Quay lại đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .controller
          .text,
      isEmpty,
    );
  });

  testWidgets('validates registration and prefills email only after success', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pumpAndSettle();

    final createAccountButton = find.widgetWithText(
      FlowFiButton,
      'Tạo tài khoản',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    expect(find.text('Vui lòng xác nhận mật khẩu'), findsOneWidget);
    expect(
      find.text('Bạn cần đồng ý với Điều khoản và Chính sách riêng tư'),
      findsOneWidget,
    );

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'New User');
    await tester.enterText(fields.at(1), 'new@example.com');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');
    await tester.tap(
      find.text('Tôi đồng ý với Điều khoản và Chính sách riêng tư.'),
    );
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(
      find.text('Đăng ký thành công. Vui lòng đăng nhập để tiếp tục.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .controller
          .text,
      'new@example.com',
    );
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
        authenticatedChild: const SizedBox(key: Key('authenticated')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('authenticated')), findsOneWidget);
  });

  testWidgets('keeps the email after sign in fails', (tester) async {
    final signInResult = Completer<AuthUser>();
    await tester.pumpWidget(
      _app(FakeAuthRepository(signInResult: signInResult.future)),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'alex@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.byType(FlowFiButton).first);
    await tester.pump();

    signInResult.completeError(Exception('Sign in failed'));
    await tester.pumpAndSettle();

    final rebuiltFields = find.byType(EditableText);
    expect(
      tester.widget<EditableText>(rebuiltFields.at(0)).controller.text,
      'alex@example.com',
    );
    expect(
      tester.widget<EditableText>(rebuiltFields.at(1)).controller.text,
      isEmpty,
    );
  });
}

Widget _app(AuthRepository repository, {Widget? authenticatedChild}) {
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
    child: MaterialApp(home: AuthGate(authenticatedChild: authenticatedChild)),
  );
}
