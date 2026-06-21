import 'dart:async';

import 'package:flowfi_fe/app/app.dart';
import 'package:flowfi_fe/features/example/domain/entities/example_item.dart';
import 'package:flowfi_fe/features/example/domain/usecases/get_example_items_use_case.dart';
import 'package:flowfi_fe/features/example/presentation/providers/example_items_provider.dart';
import 'package:flowfi_fe/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/example/test_helpers/fake_example_repository.dart';

void main() {
  testWidgets('opens the disposable example at the root route', (tester) async {
    final repository = FakeExampleRepository(
      () async => const [
        ExampleItem(id: 'one', title: 'Loaded through every layer'),
      ],
    );

    await _pumpApp(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('FlowFi'), findsOneWidget);
    expect(find.text('Disposable architecture example'), findsOneWidget);
    expect(find.text('Loaded through every layer'), findsOneWidget);
    expect(find.textContaining('pushed the button'), findsNothing);
  });

  testWidgets('shows loading while the use case is pending', (tester) async {
    final pending = Completer<List<ExampleItem>>();
    final repository = FakeExampleRepository(() => pending.future);

    await _pumpApp(tester, repository);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a stable empty state', (tester) async {
    final repository = FakeExampleRepository(() async => const []);

    await _pumpApp(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('No example items.'), findsOneWidget);
  });

  testWidgets('hides raw errors and retries the failed load', (tester) async {
    var shouldFail = true;
    final repository = FakeExampleRepository(() async {
      if (shouldFail) {
        throw StateError('sensitive internal failure');
      }
      return const [ExampleItem(id: 'recovered', title: 'Recovered item')];
    });

    await _pumpApp(tester, repository);
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load the architecture example.'),
      findsOneWidget,
    );
    expect(find.textContaining('sensitive internal failure'), findsNothing);

    shouldFail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Recovered item'), findsOneWidget);
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  FakeExampleRepository repository,
) async {
  final router = createAppRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        getExampleItemsUseCaseProvider.overrideWithValue(
          GetExampleItemsUseCase(repository),
        ),
      ],
      child: FlowFiApp(router: router),
    ),
  );
}
