import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('profile page shows and updates authenticated user details', (
    tester,
  ) async {
    final repository = authenticatedAuthRepository();
    await pumpFlowFiApp(tester, repository, initialLocation: '/profile');
    await tester.pumpAndSettle();

    expect(find.text('Hồ sơ cá nhân'), findsOneWidget);
    expect(find.text('alex@example.com'), findsWidgets);
    expect(find.text('VND'), findsWidgets);

    await tester.enterText(find.byType(EditableText).at(0), 'Alex Nguyen');
    await tester.enterText(find.byType(EditableText).at(2), '5000000');
    await tester.ensureVisible(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();

    expect(repository.updatedFullName, 'Alex Nguyen');
    expect(repository.updatedCurrencyCode, 'VND');
    expect(repository.updatedMonthlyBudgetLimit, '5000000');
  });

  testWidgets('profile page signs out through auth controller', (tester) async {
    final repository = authenticatedAuthRepository();
    await pumpFlowFiApp(tester, repository, initialLocation: '/profile');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất').last);
    await tester.pumpAndSettle();

    expect(repository.signOutCalled, isTrue);
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
