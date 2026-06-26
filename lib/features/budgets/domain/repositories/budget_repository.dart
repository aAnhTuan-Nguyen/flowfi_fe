import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Future<List<Budget>> listBudgets({int page = 1, int limit = 20});

  Future<Budget> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  });

  Future<Budget> updateBudget(
    String id, {
    String? tagId,
    String? amount,
    int? month,
    int? year,
    int? warningThresholdPercent,
  });

  Future<void> deleteBudget(String id);
}
