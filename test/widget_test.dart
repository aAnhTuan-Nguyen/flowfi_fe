import 'package:fl_chart/fl_chart.dart';
import 'package:flowfi_fe/app/app.dart';
import 'package:flowfi_fe/app/app_shell.dart';
import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/auth/domain/entities/auth_user.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/bootstrap_auth_session_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flowfi_fe/features/auth/presentation/providers/auth_controller.dart';
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
import 'package:flowfi_fe/routes/app_router.dart';
import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'features/auth/presentation/providers/auth_controller_test.dart';

void main() {
  testWidgets('opens the auth flow at the root route when signed out', (
    tester,
  ) async {
    await _pumpApp(tester, FakeAuthRepository());
    await tester.pumpAndSettle();

    expect(find.text('FlowFi'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Disposable architecture example'), findsNothing);
  });

  testWidgets('installs Forui wrappers at the app root', (tester) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    expect(find.byType(FTheme), findsOneWidget);
    expect(find.byType(FToaster), findsOneWidget);
    expect(find.byType(FTooltipGroup), findsOneWidget);
  });

  testWidgets('shows a provider-backed finance dashboard', (tester) async {
    await _pumpShell(tester);
    await tester.pumpAndSettle();

    expect(find.text('Xin chào, Alex'), findsOneWidget);
    expect(find.text('Tổng số dư'), findsOneWidget);
    expect(find.text('5.000.000 VND'), findsOneWidget);
    expect(find.text('Chi tiêu tháng này'), findsOneWidget);
    expect(find.text('120.000 VND'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Coffee House'), findsNothing);
    expect(find.text('Ngân sách nổi bật'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('switches between the four primary dashboard tabs', (
    tester,
  ) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Giao dịch'));
    await tester.pumpAndSettle();
    expect(
      find.text('Duyệt giao dịch mới, nháp và đã xác nhận.'),
      findsOneWidget,
    );
    expect(find.text('Groceries'), findsOneWidget);

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(
      find.text('Track balances across cash, bank, and e-wallets.'),
      findsOneWidget,
    );
    expect(find.text('500000'), findsOneWidget);

    await tester.tap(find.text('Ngân sách'));
    await tester.pumpAndSettle();
    expect(
      find.text('Watch monthly limits and savings progress.'),
      findsOneWidget,
    );
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Emergency Fund'), findsOneWidget);

    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
  });

  testWidgets('center add action opens the transaction launcher', (
    tester,
  ) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();

    expect(find.text('Thêm giao dịch'), findsOneWidget);
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Nói giao dịch'), findsOneWidget);
    expect(find.text('Nhập nhanh'), findsOneWidget);
  });

  testWidgets('transaction launcher opens the scan flow', (tester) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quét hóa đơn'));
    await tester.pumpAndSettle();

    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    expect(find.text('Chọn ảnh'), findsOneWidget);
  });

  testWidgets('transaction launcher opens the voice placeholder flow', (
    tester,
  ) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nói giao dịch'));
    await tester.pumpAndSettle();

    expect(find.text('Nói giao dịch'), findsOneWidget);
    expect(find.text('Voice sẽ tạo gợi ý để bạn xác nhận.'), findsOneWidget);
  });

  testWidgets('transaction launcher opens the quick manual form', (
    tester,
  ) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập nhanh'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập nhanh'), findsOneWidget);
    expect(find.text('Số tiền'), findsOneWidget);
    expect(find.text('Danh mục'), findsWidgets);
    expect(find.text('Ghi chú'), findsOneWidget);
  });

  testWidgets('quick manual form saves a confirmed transaction with defaults', (
    tester,
  ) async {
    final transactionRepository = _FakeTransactionRepository();
    await _pumpApp(
      tester,
      _authenticatedRepository(),
      transactionRepository: transactionRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập nhanh'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.ancestor(
        of: find.text('Số tiền'),
        matching: find.byType(TextFormField),
      ),
      '50000',
    );
    await tester.enterText(
      find.ancestor(
        of: find.text('Ghi chú'),
        matching: find.byType(TextFormField),
      ),
      'Cà phê sáng',
    );
    await tester.tap(find.text('Lưu giao dịch'));
    await tester.pumpAndSettle();

    expect(transactionRepository.createdWalletId, 'wallet-1');
    expect(transactionRepository.createdTagId, 'tag-1');
    expect(transactionRepository.createdTitle, 'Cà phê sáng');
    expect(transactionRepository.createdAmount, '50000');
    expect(transactionRepository.createdStatus, TransactionStatus.confirmed);
    expect(transactionRepository.createdDescription, 'Cà phê sáng');
  });

  testWidgets('home dashboard scrolls on a compact mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpShell(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ngân sách nổi bật'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();

    expect(find.text('Monthly Salary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home quick actions open scan, voice, and tags', (tester) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quét'));
    await tester.pumpAndSettle();
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voice'));
    await tester.pumpAndSettle();
    expect(find.text('Nói giao dịch'), findsOneWidget);
    expect(find.text('Voice sẽ tạo gợi ý để bạn xác nhận.'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Danh mục'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý danh mục'), findsOneWidget);
    expect(find.text('Add tag'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
  });

  testWidgets('home account menu signs out through auth controller', (
    tester,
  ) async {
    final repository = _authenticatedRepository();
    await _pumpApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalled, isTrue);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('transactions screen filters by type and status', (tester) async {
    await _pumpApp(
      tester,
      _authenticatedRepository(),
      initialLocation: AppRoutes.transactions,
    );
    await tester.pumpAndSettle();

    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Chi'), findsOneWidget);
    expect(find.text('Nháp'), findsOneWidget);
    expect(find.text('Đã xác nhận'), findsOneWidget);

    await tester.tap(find.text('Thu'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly Salary'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);

    await tester.tap(find.text('Nháp'));
    await tester.pumpAndSettle();
    expect(find.text('Chờ kiểm tra'), findsOneWidget);
    expect(find.text('Nháp'), findsWidgets);
  });

  testWidgets('transactions card actions confirm and delete entries', (
    tester,
  ) async {
    final transactionRepository = _FakeTransactionRepository();
    await _pumpApp(
      tester,
      _authenticatedRepository(),
      initialLocation: AppRoutes.transactions,
      transactionRepository: transactionRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nháp'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thao tác giao dịch').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận nháp'));
    await tester.pumpAndSettle();
    expect(transactionRepository.confirmedId, 'tx-draft');

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thao tác giao dịch').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa giao dịch'));
    await tester.pumpAndSettle();
    expect(transactionRepository.deletedId, isNotNull);
  });

  testWidgets('transactions scan and tag actions open reusable sheets', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _authenticatedRepository(),
      initialLocation: AppRoutes.transactions,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quét hóa đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quản lý danh mục'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý danh mục'), findsOneWidget);
    expect(find.text('Add tag'), findsOneWidget);
  });

  testWidgets('empty transaction views use a Lottie-backed state', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _authenticatedRepository(),
      initialLocation: AppRoutes.transactions,
      transactionRepository: _FakeTransactionRepository(transactions: const []),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có giao dịch'), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);
  });

  testWidgets('opens the home tab at the root route when authenticated', (
    tester,
  ) async {
    final router = await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.root);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
  });

  for (final routeCase in [
    (path: AppRoutes.home, text: 'Giao dịch gần đây'),
    (
      path: AppRoutes.transactions,
      text: 'Duyệt giao dịch mới, nháp và đã xác nhận.',
    ),
    (
      path: AppRoutes.wallets,
      text: 'Track balances across cash, bank, and e-wallets.',
    ),
    (
      path: AppRoutes.budgets,
      text: 'Watch monthly limits and savings progress.',
    ),
    (
      path: AppRoutes.insights,
      text: 'Notifications and backend-driven insights.',
    ),
  ]) {
    testWidgets('opens ${routeCase.path} on the matching authenticated tab', (
      tester,
    ) async {
      final router = await _pumpApp(
        tester,
        _authenticatedRepository(),
        initialLocation: routeCase.path,
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.path, routeCase.path);
      expect(find.text(routeCase.text), findsOneWidget);
    });
  }

  testWidgets('bottom navigation changes the route location', (tester) async {
    final router = await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Giao dịch'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.transactions);
    expect(
      find.text('Duyệt giao dịch mới, nháp và đã xác nhận.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.wallets);
    expect(
      find.text('Track balances across cash, bank, and e-wallets.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ngân sách'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.budgets);
    expect(
      find.text('Watch monthly limits and savings progress.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.home);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
  });
}

Future<GoRouter> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository repository, {
  String initialLocation = AppRoutes.root,
  _FakeTransactionRepository? transactionRepository,
}) async {
  final router = createAppRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        bootstrapAuthSessionUseCaseProvider.overrideWithValue(
          BootstrapAuthSessionUseCase(repository),
        ),
        signInUseCaseProvider.overrideWithValue(SignInUseCase(repository)),
        signUpUseCaseProvider.overrideWithValue(SignUpUseCase(repository)),
        signOutUseCaseProvider.overrideWithValue(SignOutUseCase(repository)),
        transactionRepositoryProvider.overrideWithValue(
          transactionRepository ?? _FakeTransactionRepository(),
        ),
        walletRepositoryProvider.overrideWithValue(_FakeWalletRepository()),
        tagRepositoryProvider.overrideWithValue(_FakeTagRepository()),
        budgetRepositoryProvider.overrideWithValue(_FakeBudgetRepository()),
        goalRepositoryProvider.overrideWithValue(_FakeGoalRepository()),
        notificationRepositoryProvider.overrideWithValue(
          _FakeNotificationRepository(),
        ),
      ],
      child: FlowFiApp(router: router),
    ),
  );
  return router;
}

FakeAuthRepository _authenticatedRepository() {
  return FakeAuthRepository(
    bootstrappedUser: const AuthUser(
      id: 'user-1',
      email: 'alex@example.com',
      fullName: 'Alex Morgan',
      currencyCode: 'VND',
    ),
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  final authRepository = _authenticatedRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        bootstrapAuthSessionUseCaseProvider.overrideWithValue(
          BootstrapAuthSessionUseCase(authRepository),
        ),
        signInUseCaseProvider.overrideWithValue(SignInUseCase(authRepository)),
        signUpUseCaseProvider.overrideWithValue(SignUpUseCase(authRepository)),
        signOutUseCaseProvider.overrideWithValue(
          SignOutUseCase(authRepository),
        ),
        transactionRepositoryProvider.overrideWithValue(
          _FakeTransactionRepository(),
        ),
        walletRepositoryProvider.overrideWithValue(_FakeWalletRepository()),
        tagRepositoryProvider.overrideWithValue(_FakeTagRepository()),
        budgetRepositoryProvider.overrideWithValue(_FakeBudgetRepository()),
        goalRepositoryProvider.overrideWithValue(_FakeGoalRepository()),
        notificationRepositoryProvider.overrideWithValue(
          _FakeNotificationRepository(),
        ),
      ],
      child: const MaterialApp(home: FlowFiAppShell()),
    ),
  );
}

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository({List<Transaction>? transactions})
    : _transactions = transactions?.toList() ?? _defaultTransactions();

  static List<Transaction> _defaultTransactions() {
    return [
      Transaction(
        id: 'tx-1',
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Groceries',
        amount: '120000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 24),
        status: TransactionStatus.confirmed,
        inputMethod: TransactionInputMethod.manual,
      ),
      Transaction(
        id: 'tx-2',
        walletId: 'wallet-2',
        tagId: 'tag-2',
        title: 'Monthly Salary',
        amount: '15000000',
        type: MoneyFlowType.income,
        date: DateTime(2026, 6, 25),
        status: TransactionStatus.confirmed,
        inputMethod: TransactionInputMethod.manual,
      ),
      Transaction(
        id: 'tx-draft',
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Chờ kiểm tra',
        amount: '45000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 26),
        status: TransactionStatus.draft,
        inputMethod: TransactionInputMethod.ocr,
      ),
    ];
  }

  final List<Transaction> _transactions;
  String? createdWalletId;
  String? createdTagId;
  String? createdTitle;
  String? createdAmount;
  TransactionStatus? createdStatus;
  String? createdDescription;
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
    return _transactions;
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
  }) async {
    createdWalletId = walletId;
    createdTagId = tagId;
    createdTitle = title;
    createdAmount = amount;
    createdStatus = status;
    createdDescription = description;
    final transaction = Transaction(
      id: 'tx-new',
      walletId: walletId,
      tagId: tagId,
      title: title,
      amount: amount,
      type: type,
      date: date,
      status: status,
      inputMethod: inputMethod,
      merchantName: merchantName,
      description: description,
    );
    _transactions.insert(0, transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(
    String id, {
    String? walletId,
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    TransactionStatus? status,
    TransactionInputMethod? inputMethod,
    String? merchantName,
    String? description,
    String? clientId,
  }) async {
    return Transaction(
      id: id,
      walletId: walletId,
      tagId: tagId,
      title: title ?? 'Groceries',
      amount: amount ?? '120000',
      type: type ?? MoneyFlowType.expense,
      date: date,
      status: status ?? TransactionStatus.confirmed,
      inputMethod: inputMethod ?? TransactionInputMethod.manual,
      merchantName: merchantName,
      description: description,
    );
  }

  @override
  Future<Transaction> confirmTransaction(String id) async {
    confirmedId = id;
    final index = _transactions.indexWhere(
      (transaction) => transaction.id == id,
    );
    final current = index == -1 ? _transactions.first : _transactions[index];
    final confirmed = Transaction(
      id: current.id,
      walletId: current.walletId,
      tagId: current.tagId,
      title: current.title,
      description: current.description,
      amount: current.amount,
      type: current.type,
      date: current.date,
      status: TransactionStatus.confirmed,
      inputMethod: current.inputMethod,
      merchantName: current.merchantName,
    );
    if (index != -1) {
      _transactions[index] = confirmed;
    }
    return confirmed;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    deletedId = id;
    _transactions.removeWhere((transaction) => transaction.id == id);
  }
}

class _FakeWalletRepository implements WalletRepository {
  @override
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20}) async {
    return const [
      Wallet(
        id: 'wallet-1',
        name: 'Cash',
        type: WalletType.cash,
        balance: '500000',
        isDefault: true,
      ),
      Wallet(
        id: 'wallet-2',
        name: 'Bank',
        type: WalletType.bank,
        balance: '4500000',
        isDefault: false,
      ),
    ];
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

class _FakeTagRepository implements TagRepository {
  @override
  Future<List<Tag>> listTags({int page = 1, int limit = 50}) async {
    return const [
      Tag(
        id: 'tag-1',
        name: 'Food',
        type: MoneyFlowType.expense,
        isDefault: false,
      ),
      Tag(
        id: 'tag-2',
        name: 'Salary',
        type: MoneyFlowType.income,
        isDefault: false,
      ),
    ];
  }

  @override
  Future<Tag> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  }) async {
    return Tag(id: 'tag-new', name: name, type: type, isDefault: false);
  }

  @override
  Future<void> deleteTag(String id) async {}

  @override
  Future<Tag> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  }) async {
    return Tag(
      id: id,
      name: name ?? 'Food',
      type: type ?? MoneyFlowType.expense,
      isDefault: false,
    );
  }
}

class _FakeBudgetRepository implements BudgetRepository {
  @override
  Future<List<Budget>> listBudgets({int page = 1, int limit = 20}) async {
    return const [
      Budget(
        id: 'budget-1',
        amount: '3000000',
        month: 6,
        year: 2026,
        warningThresholdPercent: 80,
        tagName: 'Food',
      ),
    ];
  }

  @override
  Future<Budget> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  }) async {
    return Budget(
      id: 'budget-new',
      amount: amount,
      month: month,
      year: year,
      warningThresholdPercent: warningThresholdPercent,
    );
  }

  @override
  Future<void> deleteBudget(String id) async {}

  @override
  Future<Budget> updateBudget(
    String id, {
    String? tagId,
    String? amount,
    int? month,
    int? year,
    int? warningThresholdPercent,
  }) async {
    return Budget(
      id: id,
      amount: amount ?? '3000000',
      month: month ?? 6,
      year: year ?? 2026,
      warningThresholdPercent: warningThresholdPercent ?? 80,
    );
  }
}

class _FakeGoalRepository implements GoalRepository {
  @override
  Future<List<Goal>> listGoals({int page = 1, int limit = 20}) async {
    return const [
      Goal(
        id: 'goal-1',
        name: 'Emergency Fund',
        targetAmount: '10000000',
        currentAmount: '2500000',
        status: GoalStatus.active,
      ),
    ];
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
  }) async {
    return Goal(
      id: 'goal-new',
      name: name,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? '0',
      deadline: deadline,
      status: status,
    );
  }

  @override
  Future<void> deleteGoal(String id) async {}

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
  }) async {
    return Goal(
      id: id,
      name: name ?? 'Emergency Fund',
      description: description,
      targetAmount: targetAmount ?? '10000000',
      currentAmount: currentAmount ?? '2500000',
      deadline: deadline,
      status: status ?? GoalStatus.active,
    );
  }

  @override
  Future<Goal> updateGoalProgress(
    String id, {
    required String currentAmount,
  }) async {
    return Goal(
      id: id,
      name: 'Emergency Fund',
      targetAmount: '10000000',
      currentAmount: currentAmount,
      status: GoalStatus.active,
    );
  }
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> listNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    return const [
      AppNotification(
        id: 'notification-1',
        title: 'Budget warning',
        content: 'Food budget is close to the warning threshold.',
        type: AppNotificationType.budgetWarning,
        isRead: false,
      ),
    ];
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
