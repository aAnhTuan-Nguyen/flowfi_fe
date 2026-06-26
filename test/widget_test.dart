import 'package:flowfi_fe/app/app_shell.dart';
import 'package:flowfi_fe/app/app.dart';
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
import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flowfi_fe/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

  testWidgets('shows the FlowFi home dashboard in the authenticated shell', (
    tester,
  ) async {
    await _pumpShell(tester);
    await tester.pumpAndSettle();

    expect(find.text('FlowFi'), findsOneWidget);
    expect(find.text('+5,000,000 VND'), findsOneWidget);
    expect(find.text('+2.4% this month'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('AI Insights'), findsOneWidget);
    expect(find.text('Budget Health'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.text('Coffee House'), findsOneWidget);
    expect(find.text('Disposable architecture example'), findsNothing);
  });

  testWidgets('switches between the five dashboard tabs', (tester) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(
      find.text('Review the latest confirmed and draft entries.'),
      findsOneWidget,
    );
    expect(find.text('Groceries'), findsOneWidget);

    await tester.tap(find.text('Wallets'));
    await tester.pumpAndSettle();
    expect(
      find.text('Track balances across cash, bank, and e-wallets.'),
      findsOneWidget,
    );
    expect(find.text('500000'), findsOneWidget);

    await tester.tap(find.text('Budgets'));
    await tester.pumpAndSettle();
    expect(
      find.text('Watch monthly limits and savings progress.'),
      findsOneWidget,
    );
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Emergency Fund'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(
      find.text('Notifications and backend-driven insights.'),
      findsOneWidget,
    );
    expect(find.text('Budget warning'), findsOneWidget);

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

    await _pumpShell(tester);
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

  testWidgets('home scan quick action opens the image import sheet', (
    tester,
  ) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();

    expect(find.text('Scan receipt'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose image'), findsOneWidget);
  });

  testWidgets('home tags quick action opens the tag manager sheet', (
    tester,
  ) async {
    await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();

    expect(find.text('Manage tags'), findsOneWidget);
    expect(find.text('Add tag'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('home add quick action navigates to transactions', (
    tester,
  ) async {
    final router = await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.transactions);
    expect(
      find.text('Review the latest confirmed and draft entries.'),
      findsOneWidget,
    );
  });

  testWidgets('home account menu signs out through auth controller', (
    tester,
  ) async {
    final repository = _authenticatedRepository();
    await _pumpApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalled, isTrue);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('transactions scan action opens the image import sheet', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _authenticatedRepository(),
      initialLocation: AppRoutes.transactions,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Scan receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Scan receipt'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose image'), findsOneWidget);
  });

  testWidgets('transactions tag action opens the reusable tag manager', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _authenticatedRepository(),
      initialLocation: AppRoutes.transactions,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Manage tags'));
    await tester.pumpAndSettle();

    expect(find.text('Manage tags'), findsOneWidget);
    expect(find.text('Add tag'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('opens the home tab at the root route when authenticated', (
    tester,
  ) async {
    final router = await _pumpApp(tester, _authenticatedRepository());
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.root);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.text('Coffee House'), findsOneWidget);
  });

  for (final routeCase in [
    (path: AppRoutes.home, text: 'Recent Transactions'),
    (
      path: AppRoutes.transactions,
      text: 'Review the latest confirmed and draft entries.',
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

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.transactions);
    expect(
      find.text('Review the latest confirmed and draft entries.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Wallets'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.wallets);
    expect(
      find.text('Track balances across cash, bank, and e-wallets.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Budgets'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.budgets);
    expect(
      find.text('Watch monthly limits and savings progress.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.insights);
    expect(
      find.text('Notifications and backend-driven insights.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.home);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });
}

Future<GoRouter> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository repository, {
  String initialLocation = AppRoutes.root,
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
    return [
      Transaction(
        id: 'tx-1',
        title: 'Groceries',
        amount: '120000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 24),
        status: TransactionStatus.confirmed,
        inputMethod: TransactionInputMethod.manual,
      ),
    ];
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
    return Transaction(
      id: 'tx-new',
      title: title,
      amount: amount,
      type: type,
      date: date,
      status: status,
      inputMethod: inputMethod,
      merchantName: merchantName,
      description: description,
    );
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
    return Transaction(
      id: id,
      title: 'Groceries',
      amount: '120000',
      type: MoneyFlowType.expense,
      date: DateTime(2026, 6, 24),
      status: TransactionStatus.confirmed,
      inputMethod: TransactionInputMethod.manual,
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {}
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
