import 'package:flowfi_fe/app/app.dart';
import 'package:flowfi_fe/app/app_shell.dart';
import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/auth/domain/entities/auth_user.dart';
import 'package:flowfi_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/bootstrap_auth_session_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/update_profile_use_case.dart';
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
import 'package:go_router/go_router.dart';

Future<GoRouter> pumpFlowFiApp(
  WidgetTester tester,
  AuthTestRepository authRepository, {
  String initialLocation = AppRoutes.root,
  TestTransactionRepository? transactionRepository,
  TestWalletRepository? walletRepository,
  TestTagRepository? tagRepository,
  TestBudgetRepository? budgetRepository,
  TestGoalRepository? goalRepository,
  TestNotificationRepository? notificationRepository,
}) async {
  final router = createAppRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: flowFiTestOverrides(
        authRepository: authRepository,
        transactionRepository: transactionRepository,
        walletRepository: walletRepository,
        tagRepository: tagRepository,
        budgetRepository: budgetRepository,
        goalRepository: goalRepository,
        notificationRepository: notificationRepository,
      ),
      child: FlowFiApp(router: router),
    ),
  );
  return router;
}

Future<void> pumpFlowFiShell(
  WidgetTester tester, {
  AuthTestRepository? authRepository,
  TestTransactionRepository? transactionRepository,
  TestWalletRepository? walletRepository,
  TestTagRepository? tagRepository,
  TestBudgetRepository? budgetRepository,
  TestGoalRepository? goalRepository,
  TestNotificationRepository? notificationRepository,
}) async {
  final repository = authRepository ?? authenticatedAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: flowFiTestOverrides(
        authRepository: repository,
        transactionRepository: transactionRepository,
        walletRepository: walletRepository,
        tagRepository: tagRepository,
        budgetRepository: budgetRepository,
        goalRepository: goalRepository,
        notificationRepository: notificationRepository,
      ),
      child: const MaterialApp(home: FlowFiAppShell()),
    ),
  );
}

dynamic flowFiTestOverrides({
  required AuthTestRepository authRepository,
  TestTransactionRepository? transactionRepository,
  TestWalletRepository? walletRepository,
  TestTagRepository? tagRepository,
  TestBudgetRepository? budgetRepository,
  TestGoalRepository? goalRepository,
  TestNotificationRepository? notificationRepository,
}) {
  return [
    authRepositoryProvider.overrideWithValue(authRepository),
    bootstrapAuthSessionUseCaseProvider.overrideWithValue(
      BootstrapAuthSessionUseCase(authRepository),
    ),
    signInUseCaseProvider.overrideWithValue(SignInUseCase(authRepository)),
    signUpUseCaseProvider.overrideWithValue(SignUpUseCase(authRepository)),
    signOutUseCaseProvider.overrideWithValue(SignOutUseCase(authRepository)),
    updateProfileUseCaseProvider.overrideWithValue(
      UpdateProfileUseCase(authRepository),
    ),
    transactionRepositoryProvider.overrideWithValue(
      transactionRepository ?? TestTransactionRepository(),
    ),
    walletRepositoryProvider.overrideWithValue(
      walletRepository ?? TestWalletRepository(),
    ),
    tagRepositoryProvider.overrideWithValue(
      tagRepository ?? TestTagRepository(),
    ),
    budgetRepositoryProvider.overrideWithValue(
      budgetRepository ?? TestBudgetRepository(),
    ),
    goalRepositoryProvider.overrideWithValue(
      goalRepository ?? TestGoalRepository(),
    ),
    notificationRepositoryProvider.overrideWithValue(
      notificationRepository ?? TestNotificationRepository(),
    ),
  ];
}

AuthTestRepository authenticatedAuthRepository() {
  return AuthTestRepository(
    bootstrappedUser: const AuthUser(
      id: 'user-1',
      email: 'alex@example.com',
      fullName: 'Alex Morgan',
      currencyCode: 'VND',
    ),
  );
}

class AuthTestRepository implements AuthRepository {
  AuthTestRepository({this.bootstrappedUser});

  final AuthUser? bootstrappedUser;
  bool signInCalled = false;
  bool signOutCalled = false;
  String? updatedFullName;
  String? updatedCurrencyCode;
  String? updatedMonthlyBudgetLimit;

  @override
  Future<AuthUser?> bootstrap() async => bootstrappedUser;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalled = true;
    return AuthUser(
      id: 'user-1',
      email: email,
      fullName: 'Alex Morgan',
      currencyCode: 'VND',
    );
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return AuthUser(
      id: 'user-1',
      email: email,
      fullName: fullName,
      currencyCode: 'VND',
    );
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<AuthUser> updateProfile({
    String? fullName,
    String? currencyCode,
    String? monthlyBudgetLimit,
  }) async {
    updatedFullName = fullName;
    updatedCurrencyCode = currencyCode;
    updatedMonthlyBudgetLimit = monthlyBudgetLimit;
    return AuthUser(
      id: bootstrappedUser?.id ?? 'user-1',
      email: bootstrappedUser?.email ?? 'alex@example.com',
      fullName: fullName,
      currencyCode: currencyCode ?? bootstrappedUser?.currencyCode ?? 'VND',
      monthlyBudgetLimit: monthlyBudgetLimit,
    );
  }
}

class TestTransactionRepository implements TransactionRepository {
  TestTransactionRepository({List<Transaction>? transactions})
    : transactions = transactions?.toList() ?? defaultTransactions();

  static List<Transaction> defaultTransactions() {
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

  final List<Transaction> transactions;
  String? createdWalletId;
  String? createdTagId;
  String? createdTitle;
  String? createdAmount;
  TransactionStatus? createdStatus;
  String? createdDescription;
  String? updatedId;
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
    return transactions;
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
    transactions.insert(0, transaction);
    return transaction;
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
    updatedId = id;
    final current = transactions.firstWhere(
      (transaction) => transaction.id == id,
      orElse: () => transactions.first,
    );
    return Transaction(
      id: id,
      walletId: current.walletId,
      tagId: tagId,
      title: title ?? 'Groceries',
      amount: amount ?? '120000',
      type: type ?? MoneyFlowType.expense,
      date: date,
      status: current.status,
      inputMethod: current.inputMethod,
      merchantName: merchantName,
      description: description,
    );
  }

  @override
  Future<Transaction> confirmTransaction(String id) async {
    confirmedId = id;
    final index = transactions.indexWhere(
      (transaction) => transaction.id == id,
    );
    final current = index == -1 ? transactions.first : transactions[index];
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
      transactions[index] = confirmed;
    }
    return confirmed;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    deletedId = id;
    transactions.removeWhere((transaction) => transaction.id == id);
  }
}

class TestWalletRepository implements WalletRepository {
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

class TestTagRepository implements TagRepository {
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

class TestBudgetRepository implements BudgetRepository {
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

class TestGoalRepository implements GoalRepository {
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

class TestNotificationRepository implements NotificationRepository {
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
