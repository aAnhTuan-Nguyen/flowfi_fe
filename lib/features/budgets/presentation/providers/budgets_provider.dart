import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => serviceLocator<BudgetRepository>(),
);

class BudgetsNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() {
    return ref.watch(budgetRepositoryProvider).listBudgets();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  }) async {
    await ref
        .read(budgetRepositoryProvider)
        .createBudget(
          tagId: tagId,
          amount: amount,
          month: month,
          year: year,
          warningThresholdPercent: warningThresholdPercent,
        );
    await reload();
  }

  Future<void> updateBudget(
    String id, {
    String? tagId,
    String? amount,
    int? month,
    int? year,
    int? warningThresholdPercent,
  }) async {
    await ref
        .read(budgetRepositoryProvider)
        .updateBudget(
          id,
          tagId: tagId,
          amount: amount,
          month: month,
          year: year,
          warningThresholdPercent: warningThresholdPercent,
        );
    await reload();
  }

  Future<void> deleteBudget(String id) async {
    await ref.read(budgetRepositoryProvider).deleteBudget(id);
    await reload();
  }
}

final budgetsProvider = AsyncNotifierProvider<BudgetsNotifier, List<Budget>>(
  BudgetsNotifier.new,
);
