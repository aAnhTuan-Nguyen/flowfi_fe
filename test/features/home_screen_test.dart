import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('shows a provider-backed finance dashboard', (tester) async {
    await pumpFlowFiShell(tester);
    await tester.pumpAndSettle();

    expect(find.text('Xin chào, Alex'), findsOneWidget);
    expect(find.text('Tổng số dư'), findsOneWidget);
    expect(find.text('5.000.000 VND'), findsOneWidget);
    expect(find.text('Chi tiêu tháng này'), findsOneWidget);
    expect(find.text('120.000 VND'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Coffee House'), findsNothing);
    expect(find.text('Ngân sách nổi bật'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('home dashboard scrolls on a compact mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpFlowFiShell(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ngân sách nổi bật'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();

    expect(find.text('Monthly Salary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home quick actions open scan, voice, and tags', (tester) async {
    await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quét'));
    await tester.pumpAndSettle();
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voice'));
    await tester.pumpAndSettle();
    expect(find.text('Nói giao dịch'), findsOneWidget);
    expect(find.text('Voice sẽ tạo gợi ý để bạn xác nhận.'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Danh mục'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý danh mục'), findsOneWidget);
    expect(find.text('Add tag'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
  });

  testWidgets('home account menu signs out through auth controller', (
    tester,
  ) async {
    final repository = authenticatedAuthRepository();
    await pumpFlowFiApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalled, isTrue);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('home account menu opens profile edit above sign out', (
    tester,
  ) async {
    final repository = authenticatedAuthRepository();
    await pumpFlowFiApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();

    final profileItemTop = tester.getTopLeft(find.text('Chỉnh sửa hồ sơ')).dy;
    final signOutItemTop = tester.getTopLeft(find.text('Đăng xuất')).dy;
    expect(profileItemTop, lessThan(signOutItemTop));

    await tester.tap(find.text('Chỉnh sửa hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Hồ sơ cá nhân'), findsOneWidget);

    await tester.enterText(
      find.ancestor(
        of: find.text('Họ tên'),
        matching: find.byType(TextFormField),
      ),
      'Alex Nguyen',
    );
    await tester.enterText(
      find.ancestor(
        of: find.text('Hạn mức tháng'),
        matching: find.byType(TextFormField),
      ),
      '5000000',
    );
    await tester.tap(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();

    expect(repository.updatedFullName, 'Alex Nguyen');
    expect(repository.updatedCurrencyCode, 'VND');
    expect(repository.updatedMonthlyBudgetLimit, '5000000');
  });
}
