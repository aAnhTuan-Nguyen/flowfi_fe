import 'dart:async';

import 'package:flowfi_fe/app/app_theme.dart';
import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/core/local/flowfi_database.dart';
import 'package:flowfi_fe/core/local/flowfi_local_store.dart';
import 'package:flowfi_fe/core/sync/network_status_service.dart';
import 'package:flowfi_fe/di/injection.dart';
import 'package:flowfi_fe/features/sync/sync_status_banner.dart';
import 'package:flowfi_fe/features/wallets/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  setUp(() async {
    await serviceLocator.reset();
  });

  tearDown(() async {
    await serviceLocator.reset();
  });

  testWidgets('sync status chip stays hidden when sync is clean', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const SyncStatusChip()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sync-status-chip')), findsNothing);
    expect(find.textContaining('chờ đồng bộ'), findsNothing);
  });

  testWidgets(
    'sync status chip shows pending offline state and opens details',
    (tester) async {
      final database = FlowFiDatabase.inMemory();
      addTearDown(database.close);
      final store = FlowFiLocalStore(database);
      serviceLocator.registerSingleton<FlowFiLocalStore>(store);
      serviceLocator.registerSingleton<NetworkStatusService>(
        const _FixedNetworkStatus(isOnline: false),
      );
      await store.cacheWallets([
        const Wallet(
          id: 'wallet-1',
          name: 'Cash',
          type: WalletType.cash,
          balance: '500000',
          isDefault: true,
        ),
      ]);
      await store.createPendingManualTransaction(
        clientId: 'client-tx-1',
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Offline coffee',
        amount: '50000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 30),
      );

      await tester.pumpWidget(_wrap(const SyncStatusChip()));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sync-status-chip')), findsOneWidget);
      expect(find.text('1 chờ đồng bộ'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('sync-status-chip')));
      await tester.pumpAndSettle();

      expect(find.text('Trạng thái đồng bộ'), findsOneWidget);
      expect(find.text('Đang ngoại tuyến'), findsOneWidget);
    },
  );
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: FTheme(
        data: buildForuiTheme(),
        child: FToaster(
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );
}

final class _FixedNetworkStatus implements NetworkStatusService {
  const _FixedNetworkStatus({required this.isOnline});

  final bool isOnline;

  @override
  Future<bool> hasNetwork() async => isOnline;

  @override
  Stream<bool> get onlineChanges => const Stream<bool>.empty();
}
