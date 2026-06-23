import 'package:flowfi_fe/app/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the FlowFi home dashboard at the root route', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('FlowFi'), findsOneWidget);
    expect(find.text('+5,000,000 VND'), findsOneWidget);
    expect(find.text('+2.4% this month'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('AI Insights'), findsOneWidget);
    expect(find.text('Budget Health'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.text('Coffee House'), findsOneWidget);
    expect(find.text('Disposable architecture example'), findsNothing);
  });

  testWidgets('switches between the five dashboard tabs', (tester) async {
    await _pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction history will live here.'), findsOneWidget);

    await tester.tap(find.text('Wallets'));
    await tester.pumpAndSettle();
    expect(
      find.text('Wallet balances and transfers will live here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Budgets'));
    await tester.pumpAndSettle();
    expect(
      find.text('Budget limits and goals will live here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(
      find.text('AI insights and reports will live here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Transactions'), findsOneWidget);
  });

  testWidgets('home dashboard scrolls on a compact mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Budget Health'), findsOneWidget);
    expect(find.text('Coffee House'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();

    expect(find.text('Monthly Salary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: FlowFiApp()));
}
