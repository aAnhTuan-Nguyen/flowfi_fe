import 'package:flowfi_fe/core/finance/money_flow_type.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wallet mutations call repository and reload wallets', () async {
    final repository = FakeWalletRepository();
    final container = ProviderContainer(
      overrides: [walletRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(walletsProvider.future);

    await container
        .read(walletsProvider.notifier)
        .createWallet(name: 'Cash', type: WalletType.cash, balance: '100');
    await container
        .read(walletsProvider.notifier)
        .updateWallet(
          'wallet-1',
          name: 'Bank',
          type: WalletType.bank,
          balance: '200',
        );
    await container.read(walletsProvider.notifier).setDefaultWallet('wallet-1');
    await container.read(walletsProvider.notifier).deleteWallet('wallet-1');

    expect(repository.events, [
      'list',
      'create:Cash',
      'list',
      'update:wallet-1:Bank',
      'list',
      'default:wallet-1',
      'list',
      'delete:wallet-1',
      'list',
    ]);
  });

  test('tag mutations call repository and reload tags', () async {
    final repository = FakeTagRepository();
    final container = ProviderContainer(
      overrides: [tagRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(tagsProvider.future);

    await container
        .read(tagsProvider.notifier)
        .createTag(name: 'Food', type: MoneyFlowType.expense);
    await container
        .read(tagsProvider.notifier)
        .updateTag('tag-1', name: 'Dining', type: MoneyFlowType.expense);
    await container.read(tagsProvider.notifier).deleteTag('tag-1');

    expect(repository.events, [
      'list',
      'create:Food',
      'list',
      'update:tag-1:Dining',
      'list',
      'delete:tag-1',
      'list',
    ]);
  });

  test(
    'transaction mutations call repository and reload transactions',
    () async {
      final repository = FakeTransactionRepository();
      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(transactionsProvider.future);

      await container
          .read(transactionsProvider.notifier)
          .createTransaction(
            walletId: 'wallet-1',
            tagId: 'tag-1',
            title: 'Lunch',
            amount: '12.50',
            type: MoneyFlowType.expense,
            date: DateTime(2026, 1, 2),
            status: TransactionStatus.draft,
            merchantName: 'Cafe',
            description: 'Team lunch',
          );
      await container
          .read(transactionsProvider.notifier)
          .updateTransaction('transaction-1', title: 'Dinner', amount: '20');
      await container
          .read(transactionsProvider.notifier)
          .confirmTransaction('transaction-1');
      await container
          .read(transactionsProvider.notifier)
          .deleteTransaction('transaction-1');

      expect(repository.events, [
        'list',
        'create:Lunch',
        'list',
        'update:transaction-1:Dinner',
        'list',
        'confirm:transaction-1',
        'list',
        'delete:transaction-1',
        'list',
      ]);
    },
  );

  test('budget and goal mutations reload their providers', () async {
    final budgetRepository = FakeBudgetRepository();
    final goalRepository = FakeGoalRepository();
    final container = ProviderContainer(
      overrides: [
        budgetRepositoryProvider.overrideWithValue(budgetRepository),
        goalRepositoryProvider.overrideWithValue(goalRepository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(budgetsProvider.future);
    await container.read(goalsProvider.future);

    await container
        .read(budgetsProvider.notifier)
        .createBudget(
          amount: '500',
          month: 1,
          year: 2026,
          warningThresholdPercent: 80,
          tagId: 'tag-1',
        );
    await container
        .read(budgetsProvider.notifier)
        .updateBudget('budget-1', amount: '600', warningThresholdPercent: 75);
    await container.read(budgetsProvider.notifier).deleteBudget('budget-1');
    await container
        .read(goalsProvider.notifier)
        .createGoal(
          name: 'Emergency fund',
          targetAmount: '1000',
          currentAmount: '100',
          walletId: 'wallet-1',
        );
    await container
        .read(goalsProvider.notifier)
        .updateGoal('goal-1', name: 'Travel', targetAmount: '2000');
    await container
        .read(goalsProvider.notifier)
        .updateGoalProgress('goal-1', currentAmount: '250');
    await container.read(goalsProvider.notifier).deleteGoal('goal-1');

    expect(budgetRepository.events, [
      'list',
      'create:500',
      'list',
      'update:budget-1:600',
      'list',
      'delete:budget-1',
      'list',
    ]);
    expect(goalRepository.events, [
      'list',
      'create:Emergency fund',
      'list',
      'update:goal-1:Travel',
      'list',
      'progress:goal-1:250',
      'list',
      'delete:goal-1',
      'list',
    ]);
  });

  test(
    'notification mutations call repository and reload notifications',
    () async {
      final repository = FakeNotificationRepository();
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(notificationsProvider.future);

      await container
          .read(notificationsProvider.notifier)
          .markRead('notification-1');
      await container.read(notificationsProvider.notifier).markAllRead();
      await container
          .read(notificationsProvider.notifier)
          .deleteNotification('notification-1');

      expect(repository.events, [
        'list',
        'read:notification-1',
        'list',
        'read-all',
        'list',
        'delete:notification-1',
        'list',
      ]);
    },
  );
}

class FakeWalletRepository implements WalletRepository {
  final events = <String>[];

  @override
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20}) async {
    events.add('list');
    return const [];
  }

  @override
  Future<Wallet> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  }) async {
    events.add('create:$name');
    return Wallet(
      id: 'wallet-1',
      name: name,
      type: type,
      balance: balance ?? '0',
      isDefault: false,
    );
  }

  @override
  Future<void> deleteWallet(String id) async {
    events.add('delete:$id');
  }

  @override
  Future<Wallet> getWallet(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Wallet> setDefaultWallet(String id) async {
    events.add('default:$id');
    return const Wallet(
      id: 'wallet-1',
      name: 'Cash',
      type: WalletType.cash,
      balance: '0',
      isDefault: true,
    );
  }

  @override
  Future<Wallet> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  }) async {
    events.add('update:$id:$name');
    return Wallet(
      id: id,
      name: name ?? 'Cash',
      type: type ?? WalletType.cash,
      balance: balance ?? '0',
      isDefault: false,
    );
  }
}

class FakeTagRepository implements TagRepository {
  final events = <String>[];

  @override
  Future<List<Tag>> listTags({int page = 1, int limit = 50}) async {
    events.add('list');
    return const [];
  }

  @override
  Future<Tag> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  }) async {
    events.add('create:$name');
    return Tag(id: 'tag-1', name: name, type: type, isDefault: false);
  }

  @override
  Future<void> deleteTag(String id) async {
    events.add('delete:$id');
  }

  @override
  Future<Tag> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  }) async {
    events.add('update:$id:$name');
    return Tag(
      id: id,
      name: name ?? 'Food',
      type: type ?? MoneyFlowType.expense,
      isDefault: false,
    );
  }
}

class FakeTransactionRepository implements TransactionRepository {
  final events = <String>[];

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
    events.add('list');
    return const [];
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
    events.add('create:$title');
    return Transaction(
      id: 'transaction-1',
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
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) async {
    events.add('update:$id:$title');
    return Transaction(
      id: id,
      title: title ?? 'Lunch',
      amount: amount ?? '0',
      type: type ?? MoneyFlowType.expense,
      date: date,
      status: TransactionStatus.draft,
      inputMethod: TransactionInputMethod.manual,
      merchantName: merchantName,
      description: description,
    );
  }

  @override
  Future<Transaction> confirmTransaction(String id) async {
    events.add('confirm:$id');
    return Transaction(
      id: id,
      title: 'Lunch',
      amount: '0',
      type: MoneyFlowType.expense,
      date: null,
      status: TransactionStatus.confirmed,
      inputMethod: TransactionInputMethod.manual,
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    events.add('delete:$id');
  }
}

class FakeBudgetRepository implements BudgetRepository {
  final events = <String>[];

  @override
  Future<List<Budget>> listBudgets({int page = 1, int limit = 20}) async {
    events.add('list');
    return const [];
  }

  @override
  Future<Budget> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  }) async {
    events.add('create:$amount');
    return Budget(
      id: 'budget-1',
      amount: amount,
      month: month,
      year: year,
      warningThresholdPercent: warningThresholdPercent,
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    events.add('delete:$id');
  }

  @override
  Future<Budget> updateBudget(
    String id, {
    String? tagId,
    String? amount,
    int? month,
    int? year,
    int? warningThresholdPercent,
  }) async {
    events.add('update:$id:$amount');
    return Budget(
      id: id,
      amount: amount ?? '0',
      month: month ?? 1,
      year: year ?? 2026,
      warningThresholdPercent: warningThresholdPercent ?? 80,
    );
  }
}

class FakeGoalRepository implements GoalRepository {
  final events = <String>[];

  @override
  Future<List<Goal>> listGoals({int page = 1, int limit = 20}) async {
    events.add('list');
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
  }) async {
    events.add('create:$name');
    return Goal(
      id: 'goal-1',
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? '0',
      deadline: deadline,
      status: status,
      description: description,
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    events.add('delete:$id');
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
  }) async {
    events.add('update:$id:$name');
    return Goal(
      id: id,
      name: name ?? 'Emergency fund',
      description: description,
      targetAmount: targetAmount ?? '0',
      currentAmount: currentAmount ?? '0',
      deadline: deadline,
      status: status ?? GoalStatus.active,
    );
  }

  @override
  Future<Goal> updateGoalProgress(
    String id, {
    required String currentAmount,
  }) async {
    events.add('progress:$id:$currentAmount');
    return Goal(
      id: id,
      name: 'Emergency fund',
      targetAmount: '1000',
      currentAmount: currentAmount,
      status: GoalStatus.active,
    );
  }
}

class FakeNotificationRepository implements NotificationRepository {
  final events = <String>[];

  @override
  Future<List<AppNotification>> listNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    events.add('list');
    return const [];
  }

  @override
  Future<void> deleteNotification(String id) async {
    events.add('delete:$id');
  }

  @override
  Future<void> markAllRead() async {
    events.add('read-all');
  }

  @override
  Future<void> markRead(String id) async {
    events.add('read:$id');
  }
}
