import 'package:flowfi_fe/app/app.dart';
import 'package:flowfi_fe/core/constants/app_constants.dart';
import 'package:flowfi_fe/routes/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the FlowFi splash screen at the root route', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('FlowFi'), findsOneWidget);
    expect(find.text('Smart Finance Management'), findsOneWidget);

    await tester.pump(
      AppConstants.splashDuration + const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('redirects from splash to login', (tester) async {
    await _pumpApp(tester);

    await tester
        .pump(AppConstants.splashDuration + const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Access your secure financial dashboard'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(child: FlowFiApp(router: createAppRouter())),
  );
}
