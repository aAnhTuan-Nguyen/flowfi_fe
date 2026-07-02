import 'package:fl_chart/fl_chart.dart';
import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('budgets screen has segmented budget and goal views with chart', (
    tester,
  ) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.budgets,
    );
    await tester.pumpAndSettle();

    expect(find.text('Ngân sách'), findsWidgets);
    expect(find.text('Mục tiêu'), findsOneWidget);
    expect(
      find.text('Theo dõi hạn mức tháng và tiến độ tiết kiệm.'),
      findsOneWidget,
    );
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
    expect(find.byType(PopupMenuButton), findsNothing);
    expect(find.text('Emergency Fund'), findsNothing);

    await tester.tap(find.text('Mục tiêu'));
    await tester.pumpAndSettle();

    expect(find.text('Emergency Fund'), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
  });
}
