import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/ai_processing/domain/entities/image_transaction_import.dart';
import 'package:flowfi_fe/features/ai_processing/domain/repositories/ai_processing_repository.dart';
import 'package:flowfi_fe/features/ai_processing/presentation/providers/image_transaction_import_provider.dart';
import 'package:flowfi_fe/features/ai_processing/presentation/widgets/image_transaction_import_sheet.dart';
import 'package:flowfi_fe/features/ai_processing/domain/entities/ai_image_file.dart';
import 'package:flowfi_fe/features/budgets/domain/entities/budget.dart';
import 'package:flowfi_fe/features/budgets/domain/repositories/budget_repository.dart';
import 'package:flowfi_fe/features/budgets/presentation/providers/budgets_provider.dart';
import 'package:flowfi_fe/features/goals/domain/entities/goal.dart';
import 'package:flowfi_fe/features/goals/domain/repositories/goal_repository.dart';
import 'package:flowfi_fe/features/goals/presentation/providers/goals_provider.dart';
import 'package:flowfi_fe/features/notifications/domain/entities/app_notification.dart';
import 'package:flowfi_fe/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flowfi_fe/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:flowfi_fe/features/tags/domain/entities/tag.dart';
import 'package:flowfi_fe/features/tags/domain/repositories/tag_repository.dart';
import 'package:flowfi_fe/features/tags/presentation/providers/tags_provider.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flowfi_fe/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flowfi_fe/features/transactions/presentation/providers/transactions_provider.dart';
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

  testWidgets('explains that scanned images create OCR drafts for review', (
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
        'AI sẽ tạo nháp từ hóa đơn. Kiểm tra lại trước khi xác nhận để số dư ví không bị đổi nhầm.',
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

  testWidgets('reviews and confirms OCR drafts after scanning an image', (
    tester,
  ) async {
    final walletRepository = FakeWalletRepository(wallets: _wallets);
    final transactionRepository = FakeTransactionRepository();
    final budgetRepository = FakeBudgetRepository();
    final goalRepository = FakeGoalRepository();
    final notificationRepository = FakeNotificationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiProcessingRepositoryProvider.overrideWithValue(
            FakeAiProcessingRepository(),
          ),
          transactionRepositoryProvider.overrideWithValue(
            transactionRepository,
          ),
          walletRepositoryProvider.overrideWithValue(walletRepository),
          tagRepositoryProvider.overrideWithValue(FakeTagRepository()),
          budgetRepositoryProvider.overrideWithValue(budgetRepository),
          goalRepositoryProvider.overrideWithValue(goalRepository),
          notificationRepositoryProvider.overrideWithValue(
            notificationRepository,
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
    final walletLoadsBeforeScan = walletRepository.listCalls;
    await tester.tap(find.text('Quét ảnh'));
    await tester.pumpAndSettle();

    expect(
      find.text('AI đã tạo nháp từ hóa đơn. Kiểm tra trước khi xác nhận.'),
      findsOneWidget,
    );
    expect(find.text('Receipt Winmart'), findsOneWidget);
    expect(find.text('Nháp · OCR'), findsOneWidget);
    expect(find.text('Sửa'), findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);
    expect(find.text('Xóa'), findsOneWidget);
    expect(walletRepository.listCalls, walletLoadsBeforeScan);
    expect(transactionRepository.listCalls, greaterThanOrEqualTo(1));
    expect(notificationRepository.listCalls, greaterThanOrEqualTo(1));

    final walletLoadsBeforeConfirm = walletRepository.listCalls;
    await tester.ensureVisible(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();

    expect(transactionRepository.confirmedId, 'transaction-ocr');
    expect(walletRepository.listCalls, walletLoadsBeforeConfirm + 1);
    expect(budgetRepository.listCalls, greaterThanOrEqualTo(1));
    expect(goalRepository.listCalls, greaterThanOrEqualTo(1));
    expect(notificationRepository.listCalls, greaterThanOrEqualTo(2));
  });

  testWidgets('deletes OCR drafts without refreshing wallet balance', (
    tester,
  ) async {
    final walletRepository = FakeWalletRepository(wallets: _wallets);
    final transactionRepository = FakeTransactionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiProcessingRepositoryProvider.overrideWithValue(
            FakeAiProcessingRepository(),
          ),
          transactionRepositoryProvider.overrideWithValue(
            transactionRepository,
          ),
          walletRepositoryProvider.overrideWithValue(walletRepository),
          tagRepositoryProvider.overrideWithValue(FakeTagRepository()),
          notificationRepositoryProvider.overrideWithValue(
            FakeNotificationRepository(),
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
    await tester.tap(find.text('Quét ảnh'));
    await tester.pumpAndSettle();
    final walletLoadsBeforeDelete = walletRepository.listCalls;
    await tester.ensureVisible(find.text('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa giao dịch'));
    await tester.pumpAndSettle();

    expect(transactionRepository.deletedId, 'transaction-ocr');
    expect(walletRepository.listCalls, walletLoadsBeforeDelete);
  });
}

final class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository({this.wallets = const []});

  final List<Wallet> wallets;
  int listCalls = 0;

  @override
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20}) async {
    listCalls += 1;
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

final class FakeAiProcessingRepository implements AiProcessingRepository {
  @override
  Future<ImageTransactionImport> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  }) async {
    return ImageTransactionImport(
      aiRequestId: 'request-1',
      aiResultId: 'result-1',
      imageUrl: 'local://receipt.png',
      imageType: 'RECEIPT',
      createdTransactions: [
        CreatedImageTransaction(
          transaction: _draftOcrTransaction,
          tagCreated: false,
        ),
      ],
    );
  }
}

final class FakeTransactionRepository implements TransactionRepository {
  int listCalls = 0;
  String? confirmedId;
  String? deletedId;

  @override
  Future<List<Transaction>> listTransactions({
    int page = 1,
    int limit = 20,
    String? walletId,
    String? tagId,
    MoneyFlowType? transactionType,
    TransactionStatus? status,
    TransactionInputMethod? inputMethod,
    String? keyword,
    String? from,
    String? to,
  }) async {
    listCalls += 1;
    return [_draftOcrTransaction];
  }

  @override
  Future<Transaction> createTransaction({
    required String walletId,
    required String tagId,
    required String title,
    required String amount,
    required MoneyFlowType type,
    required DateTime date,
    TransactionStatus status = TransactionStatus.draft,
    TransactionInputMethod inputMethod = TransactionInputMethod.manual,
    String? merchantName,
    String? description,
    String? clientId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Transaction> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) async {
    return Transaction(
      id: id,
      walletId: _draftOcrTransaction.walletId,
      tagId: tagId ?? _draftOcrTransaction.tagId,
      title: title ?? _draftOcrTransaction.title,
      description: description ?? _draftOcrTransaction.description,
      amount: amount ?? _draftOcrTransaction.amount,
      type: type ?? _draftOcrTransaction.type,
      date: date ?? _draftOcrTransaction.date,
      status: _draftOcrTransaction.status,
      inputMethod: _draftOcrTransaction.inputMethod,
      merchantName: merchantName ?? _draftOcrTransaction.merchantName,
    );
  }

  @override
  Future<Transaction> confirmTransaction(String id) async {
    confirmedId = id;
    return Transaction(
      id: id,
      walletId: _draftOcrTransaction.walletId,
      tagId: _draftOcrTransaction.tagId,
      title: _draftOcrTransaction.title,
      description: _draftOcrTransaction.description,
      amount: _draftOcrTransaction.amount,
      type: _draftOcrTransaction.type,
      date: _draftOcrTransaction.date,
      status: TransactionStatus.confirmed,
      inputMethod: _draftOcrTransaction.inputMethod,
      merchantName: _draftOcrTransaction.merchantName,
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    deletedId = id;
  }
}

final class FakeTagRepository implements TagRepository {
  @override
  Future<List<Tag>> listTags({int page = 1, int limit = 50}) async {
    return const [
      Tag(
        id: 'tag-1',
        name: 'Food',
        type: MoneyFlowType.expense,
        isDefault: false,
      ),
    ];
  }

  @override
  Future<Tag> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTag(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Tag> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  }) {
    throw UnimplementedError();
  }
}

final class FakeBudgetRepository implements BudgetRepository {
  int listCalls = 0;

  @override
  Future<List<Budget>> listBudgets({int page = 1, int limit = 20}) async {
    listCalls += 1;
    return const [];
  }

  @override
  Future<Budget> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBudget(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Budget> updateBudget(
    String id, {
    String? tagId,
    String? amount,
    int? month,
    int? year,
    int? warningThresholdPercent,
  }) {
    throw UnimplementedError();
  }
}

final class FakeGoalRepository implements GoalRepository {
  int listCalls = 0;

  @override
  Future<List<Goal>> listGoals({int page = 1, int limit = 20}) async {
    listCalls += 1;
    return const [];
  }

  @override
  Future<Goal> createGoal({
    String? walletId,
    required String name,
    String? description,
    required String targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus status = GoalStatus.active,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteGoal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Goal> updateGoal(
    String id, {
    String? walletId,
    String? name,
    String? description,
    String? targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus? status,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Goal> updateGoalProgress(String id, {required String currentAmount}) {
    throw UnimplementedError();
  }
}

final class FakeNotificationRepository implements NotificationRepository {
  int listCalls = 0;

  @override
  Future<List<AppNotification>> listNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    listCalls += 1;
    return const [];
  }

  @override
  Future<void> deleteNotification(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> markAllRead() {
    throw UnimplementedError();
  }

  @override
  Future<void> markRead(String id) {
    throw UnimplementedError();
  }
}

final _draftOcrTransaction = Transaction(
  id: 'transaction-ocr',
  walletId: 'wallet-1',
  tagId: 'tag-1',
  title: 'Receipt Winmart',
  description: 'Imported from receipt',
  amount: '125000',
  type: MoneyFlowType.expense,
  date: DateTime(2026, 6, 27, 8),
  status: TransactionStatus.draft,
  inputMethod: TransactionInputMethod.ocr,
  merchantName: 'Winmart',
);

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
