import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('wallets screen uses Vietnamese copy and opens a compact form', (
    tester,
  ) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.wallets,
    );
    await tester.pumpAndSettle();

    expect(find.text('Ví'), findsWidgets);
    expect(
      find.text('Theo dõi tiền mặt, ngân hàng và ví điện tử.'),
      findsOneWidget,
    );
    expect(find.text('Thêm ví'), findsOneWidget);
    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Tiền mặt'), findsOneWidget);
    expect(find.text('Ngân hàng'), findsOneWidget);

    await tester.tap(find.text('Thêm ví'));
    await tester.pumpAndSettle();

    expect(find.text('Thêm ví mới'), findsOneWidget);
    expect(find.text('Tên ví'), findsOneWidget);
    expect(find.text('Loại ví'), findsOneWidget);
    expect(find.text('Số dư ban đầu'), findsOneWidget);
  });
}
