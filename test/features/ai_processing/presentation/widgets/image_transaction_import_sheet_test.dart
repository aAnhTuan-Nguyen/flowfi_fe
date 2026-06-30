import 'package:flowfi_fe/features/ai_processing/presentation/widgets/image_transaction_import_sheet.dart';
import 'package:flowfi_fe/features/ai_processing/domain/entities/ai_image_file.dart';
import 'package:flowfi_fe/features/wallets/domain/entities/wallet.dart';
import 'package:flowfi_fe/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:flowfi_fe/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows an empty wallet message before image upload controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ImageTransactionImportSheet()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tạo ít nhất một ví trước khi quét hóa đơn.'), findsOne);
    expect(find.text('Chụp ảnh'), findsNothing);
    expect(find.text('Chọn ảnh'), findsNothing);
  });

  testWidgets('explains that scanned images create confirmed transactions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(
            FakeWalletRepository(wallets: _wallets),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ImageTransactionImportSheet()),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'AI sẽ đọc hóa đơn. Hiện backend tạo giao dịch sau khi quét, nên hãy kiểm tra lại kết quả ngay.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a thumbnail after choosing an image', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(
            FakeWalletRepository(wallets: _wallets),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ImageTransactionImportSheet(
              pickImageFile: (_) async => const AiImageFile(
                name: 'receipt.png',
                bytes: _tinyPngBytes,
                mimeType: 'image/png',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Chọn ảnh'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('receipt.png'), findsOneWidget);
  });
}

final class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository({this.wallets = const []});

  final List<Wallet> wallets;

  @override
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20}) async {
    return wallets;
  }

  @override
  Future<Wallet> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWallet(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Wallet> getWallet(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Wallet> setDefaultWallet(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Wallet> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  }) {
    throw UnimplementedError();
  }
}

const _wallets = [
  Wallet(
    id: 'wallet-1',
    name: 'Cash',
    type: WalletType.cash,
    balance: '500000',
    isDefault: true,
  ),
];

const _tinyPngBytes = [
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  13,
  73,
  68,
  65,
  84,
  120,
  156,
  99,
  248,
  15,
  4,
  0,
  9,
  251,
  3,
  253,
  160,
  55,
  244,
  165,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130,
];
