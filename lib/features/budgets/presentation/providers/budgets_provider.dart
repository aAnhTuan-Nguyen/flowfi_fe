import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/monthly_budget_details.dart';
import '../../domain/entities/annual_budget_summary.dart';
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

  Future<void> saveTarget({
    required int month,
    required int year,
    required int warningThresholdPercent,
    required List<BudgetAllocation> allocations,
  }) async {
    await ref
        .read(budgetRepositoryProvider)
        .saveTarget(
          month: month,
          year: year,
          warningThresholdPercent: warningThresholdPercent,
          allocations: allocations,
        );
    await reload();
  }
}

final budgetsProvider = AsyncNotifierProvider<BudgetsNotifier, List<Budget>>(
  BudgetsNotifier.new,
);

final monthlyBudgetDetailsProvider = FutureProvider.autoDispose
    .family<MonthlyBudgetDetails, ({int month, int year})>((ref, period) {
      return ref
          .watch(budgetRepositoryProvider)
          .getMonthlyDetails(month: period.month, year: period.year);
    });

final annualBudgetSummaryProvider = FutureProvider.autoDispose
    .family<List<AnnualBudgetMonthSummary>, int>((ref, year) {
      return ref.watch(budgetRepositoryProvider).getAnnualSummary(year);
    });
