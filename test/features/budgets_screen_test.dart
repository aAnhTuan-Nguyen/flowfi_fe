import 'package:fl_chart/fl_chart.dart';
import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('budgets screen shows yearly month grid and budget chart', (
    tester,
  ) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.budgets,
    );
    await tester.pumpAndSettle();

    expect(find.text('Ngân sách năm'), findsOneWidget);
    expect(
      find.text('Theo dõi mục tiêu chi tiêu theo 12 tháng'),
      findsOneWidget,
    );
    expect(find.text('T1'), findsWidgets);
    expect(find.text('T12'), findsWidgets);
    expect(find.text('+328%'), findsOneWidget);
    expect(find.text('Vượt mức · 11.6tr'), findsOneWidget);
    expect(find.text('Chi tiêu năm 2026'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);

    await tester.tap(find.text('T8').first);
    await tester.pumpAndSettle();

    expect(find.text('Thiết lập Target'), findsOneWidget);
    expect(find.text('Ngân sách mục tiêu'), findsOneWidget);
    expect(find.text('Phân bổ theo danh mục'), findsOneWidget);
  });

  testWidgets('tapping a configured month opens its monthly details', (
    tester,
  ) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.budgets,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('T6').first);
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết tháng 6'), findsOneWidget);
    expect(find.text('Tổng quan tháng'), findsOneWidget);
    expect(find.text('Chi tiêu theo danh mục'), findsOneWidget);
    expect(find.text('So với target'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('8.850.000đ'), findsOneWidget);
    expect(find.text('+328%  Vượt mức'), findsOneWidget);
  });
}
