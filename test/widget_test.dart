import 'package:flowfi_fe/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('opens the auth flow at the root route when signed out', (
    tester,
  ) async {
    await pumpFlowFiApp(tester, AuthTestRepository());
    await tester.pumpAndSettle();

    expect(find.text('FlowFi'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Disposable architecture example'), findsNothing);
  });

  testWidgets('installs Forui wrappers at the app root', (tester) async {
    await pumpFlowFiApp(
      tester,
      AuthTestRepository(
        bootstrappedUser: const AuthUser(
          id: 'user-1',
          email: 'alex@example.com',
          fullName: 'Alex Morgan',
          currencyCode: 'VND',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FTheme), findsOneWidget);
    expect(find.byType(FToaster), findsOneWidget);
    expect(find.byType(FTooltipGroup), findsOneWidget);
  });
}
