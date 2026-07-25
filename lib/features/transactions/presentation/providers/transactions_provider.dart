import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => serviceLocator<TransactionRepository>(),
);

class TransactionsMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime month) => state = month;
}

final transactionsMonthProvider =
    NotifierProvider<TransactionsMonthNotifier, DateTime>(
      TransactionsMonthNotifier.new,
    );

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool get hasMore => _hasMore;

  @override
  Future<List<Transaction>> build() async {
    _page = 1;
    _hasMore = true;
    final month = ref.watch(transactionsMonthProvider);
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));

    final transactions = await ref
        .watch(transactionRepositoryProvider)
        .listTransactions(
          page: _page,
          limit: 20,
          from: startOfMonth.toIso8601String(),
          to: endOfMonth.toIso8601String(),
        );

    final filtered = transactions.where((t) {
      if (t.date == null) return false;
      return t.date!.year == month.year && t.date!.month == month.month;
    }).toList();

    if (transactions.length < 20) {
      _hasMore = false;
    }
    return sortTransactionsByActivity(filtered);
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || state.isRefreshing || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    _page++;
    try {
      final month = ref.read(transactionsMonthProvider);
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(
        month.year,
        month.month + 1,
        1,
      ).subtract(const Duration(milliseconds: 1));

      final newTransactions = await ref
          .read(transactionRepositoryProvider)
          .listTransactions(
            page: _page,
            limit: 20,
            from: startOfMonth.toIso8601String(),
            to: endOfMonth.toIso8601String(),
          );

      final filtered = newTransactions.where((t) {
        if (t.date == null) return false;
        return t.date!.year == month.year && t.date!.month == month.month;
      }).toList();

      if (newTransactions.length < 20) {
        _hasMore = false;
      }

      final currentList = state.value ?? [];
      state = AsyncData(
        sortTransactionsByActivity([...currentList, ...filtered]),
      );
    } catch (e, st) {
      _page--;
      state = AsyncError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createTransaction({
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
    await ref
        .read(transactionRepositoryProvider)
        .createTransaction(
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
          clientId: clientId,
        );
    await reload();
    _invalidateDerivedTransactionData();
  }

  Future<void> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) async {
    await ref
        .read(transactionRepositoryProvider)
        .updateTransaction(
          id,
          tagId: tagId,
          title: title,
          amount: amount,
          type: type,
          date: date,
          merchantName: merchantName,
          description: description,
        );
    await reload();
    _invalidateDerivedTransactionData();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    await reload();
    _invalidateDerivedTransactionData();
  }

  Future<void> confirmTransaction(String id) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.confirmTransaction(id);
    await reload();
    _invalidateDerivedTransactionData();
  }

  void _invalidateDerivedTransactionData() {
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(monthlyTransactionSummaryProvider);
    ref.invalidate(annualTransactionsProvider);
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );

final monthlyTransactionsProvider = FutureProvider.autoDispose
    .family<List<Transaction>, DateTime>((ref, month) async {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(
        month.year,
        month.month + 1,
        1,
      ).subtract(const Duration(milliseconds: 1));

      final transactions = await _listAllTransactions(
        ref.watch(transactionRepositoryProvider),
        from: startOfMonth,
        to: endOfMonth,
      );

      final filtered = transactions.where((t) {
        if (t.date == null) return false;
        return t.date!.year == month.year && t.date!.month == month.month;
      }).toList();

      return sortTransactionsByActivity(filtered);
    });

final monthlyTransactionSummaryProvider = FutureProvider.autoDispose
    .family<TransactionSummary, DateTime>((ref, month) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(
        month.year,
        month.month + 1,
        1,
      ).subtract(const Duration(milliseconds: 1));
      return ref
          .watch(transactionRepositoryProvider)
          .getSummary(
            from: startOfMonth.toIso8601String(),
            to: endOfMonth.toIso8601String(),
          );
    });

final expenseTrendTransactionsProvider = FutureProvider.autoDispose
    .family<List<Transaction>, DateTime>((ref, now) async {
      final today = DateTime(now.year, now.month, now.day);
      final currentMonday = today.subtract(Duration(days: today.weekday - 1));
      final start = currentMonday.subtract(const Duration(days: 91));
      final end = currentMonday
          .add(const Duration(days: 7))
          .subtract(const Duration(milliseconds: 1));
      final transactions = await _listAllTransactions(
        ref.watch(transactionRepositoryProvider),
        from: start,
        to: end,
      );
      return sortTransactionsByActivity(
        transactions.where((transaction) {
          final date = transaction.date;
          return date != null && !date.isBefore(start) && !date.isAfter(end);
        }),
      );
    });

final annualTransactionsProvider = FutureProvider.autoDispose
    .family<List<Transaction>, int>((ref, year) async {
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(
        year + 1,
        1,
        1,
      ).subtract(const Duration(milliseconds: 1));

      final transactions = await _listAllTransactions(
        ref.watch(transactionRepositoryProvider),
        from: startOfYear,
        to: endOfYear,
      );

      final filtered = transactions.where((t) {
        if (t.date == null) return false;
        return t.date!.year == year;
      }).toList();

      return sortTransactionsByActivity(filtered);
    });

Future<List<Transaction>> _listAllTransactions(
  TransactionRepository repository, {
  required DateTime from,
  required DateTime to,
}) async {
  const pageSize = 100;
  final items = <Transaction>[];
  var page = 1;
  while (true) {
    final batch = await repository.listTransactions(
      page: page,
      limit: pageSize,
      from: from.toIso8601String(),
      to: to.toIso8601String(),
    );
    items.addAll(batch);
    if (batch.length < pageSize) {
      return items;
    }
    page += 1;
  }
}
