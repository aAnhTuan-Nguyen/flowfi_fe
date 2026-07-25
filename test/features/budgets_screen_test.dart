import 'package:fl_chart/fl_chart.dart';
import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flutter/material.dart';
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
    expect(find.text('Đã vượt 328%'), findsOneWidget);
    expect(find.text('Đã đạt 64%'), findsOneWidget);
    expect(find.text('ngân sách'), findsNWidgets(2));
    expect(find.text('+328%'), findsNothing);
    expect(find.text('Vượt mức · 11.6tr'), findsNothing);
    final exceededProgress = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('budget-progress-6')),
    );
    final safeProgress = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('budget-progress-7')),
    );
    expect(exceededProgress.color, const Color(0xFFD9362B));
    expect(safeProgress.color, const Color(0xFF356B2B));
    expect(exceededProgress.value, 1);
    expect(safeProgress.value, 0.64);
    expect(find.text('Tiết kiệm và Vượt chi'), findsOneWidget);
    expect(find.text('Tiết kiệm'), findsNWidgets(2));
    expect(find.text('Vượt chi'), findsNWidgets(2));
    final varianceTitle = tester.widget<Text>(
      find.byKey(const ValueKey('annual-variance-title')),
    );
    expect(varianceTitle.maxLines, 1);
    expect(find.text('+108,2tr'), findsOneWidget);
    final overspending = tester.widget<Text>(
      find.byKey(const ValueKey('annual-variance-Vượt chi')),
    );
    expect(overspending.data, startsWith('-8,'));
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
    final varianceChart = tester.widget<BarChart>(find.byType(BarChart));
    expect(varianceChart.data.minY, lessThan(0));
    expect(varianceChart.data.maxY, greaterThan(0));
    expect(varianceChart.data.barGroups[5].barRods.single.toY, lessThan(0));
    expect(
      varianceChart.data.barGroups[5].barRods.single.color,
      const Color(0xFFD9362B),
    );
    expect(varianceChart.data.barGroups[6].barRods.single.toY, greaterThan(0));
    expect(
      varianceChart.data.barGroups[6].barRods.single.color,
      const Color(0xFF356B2B),
    );

    await tester.tap(find.text('T8').first);
    await tester.pumpAndSettle();

    expect(find.text('Thiết lập Target'), findsOneWidget);
    expect(find.text('Ngân sách mục tiêu'), findsOneWidget);
    expect(find.text('Phân bổ theo danh mục'), findsOneWidget);

    final addCategoryButton = find.byKey(const Key('add-target-category'));
    expect(addCategoryButton, findsOneWidget);
    await tester.tap(addCategoryButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tag-name-field')), findsOneWidget);
    expect(find.text('Tạo danh mục'), findsOneWidget);
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
    expect(find.text('Tiến độ chi tiêu theo Danh mục'), findsOneWidget);
    expect(find.text('Chi tiêu theo danh mục'), findsNothing);
    expect(find.text('So với target'), findsNothing);
    expect(find.text('Ăn uống'), findsWidgets);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('10.000.000đ / 10.000.000đ'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('0đ / 5.000.000đ'), findsOneWidget);
    expect(find.text('Khác'), findsOneWidget);
    expect(find.text('Không có Target'), findsOneWidget);
    expect(
      find.text('Đã chi 680.000đ từ các danh mục chưa thiết lập · Nhấn để xem'),
      findsOneWidget,
    );
    final foodProgress = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('category-progress-tag-food')),
    );
    expect(foodProgress.value, 1);

    final otherDetails = find.byKey(
      const ValueKey('unbudgeted-categories-details'),
    );
    await tester.ensureVisible(otherDetails);
    await tester.pumpAndSettle();
    await tester.tap(otherDetails);
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết danh mục Khác'), findsOneWidget);
    expect(find.text('Mua sắm'), findsOneWidget);
    expect(find.text('500.000đ'), findsOneWidget);
    expect(find.text('Giải trí'), findsOneWidget);
    expect(find.text('180.000đ'), findsOneWidget);
    expect(find.text('Tổng chi chưa có Target'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('8.850.000đ'), findsOneWidget);
    expect(find.text('+328%  Vượt mức'), findsOneWidget);
  });

  testWidgets('warns before leaving Target with unsaved changes', (
    tester,
  ) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.budgets,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('T8').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).last, '1000000');
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('target-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('Thay đổi chưa được lưu'), findsOneWidget);
    expect(find.text('Bỏ thay đổi'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục chỉnh sửa'));
    await tester.pumpAndSettle();
    expect(find.text('Thiết lập Target'), findsOneWidget);

    await tester.tap(find.byKey(const Key('target-cancel-button')));
    await tester.pumpAndSettle();
    expect(find.text('Thay đổi chưa được lưu'), findsOneWidget);

    await tester.tap(find.byKey(const Key('discard-target-changes')));
    await tester.pumpAndSettle();
    expect(find.text('Thiết lập Target'), findsNothing);
  });
}
