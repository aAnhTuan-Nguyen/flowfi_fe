import '../../domain/entities/budget.dart';
import '../../domain/entities/monthly_budget_details.dart';
import '../../domain/entities/annual_budget_summary.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_data_source.dart';

final class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl(this._remoteDataSource);

  final BudgetRemoteDataSource _remoteDataSource;

  @override
  Future<List<Budget>> listBudgets({int page = 1, int limit = 20}) async {
    final models = await _remoteDataSource.listBudgets(
      page: page,
      limit: limit,
    );
    return models.map((model) => model.toDomain()).toList(growable: false);
  }

  @override
  Future<Budget> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  }) async {
    return (await _remoteDataSource.createBudget(
      tagId: tagId,
      amount: amount,
      month: month,
      year: year,
      warningThresholdPercent: warningThresholdPercent,
    )).toDomain();
  }

  @override
  Future<void> deleteBudget(String id) {
    return _remoteDataSource.deleteBudget(id);
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
    return (await _remoteDataSource.updateBudget(
      id,
      tagId: tagId,
      amount: amount,
      month: month,
      year: year,
      warningThresholdPercent: warningThresholdPercent,
    )).toDomain();
  }

  @override
  Future<List<Budget>> saveTarget({
    required int month,
    required int year,
    required int warningThresholdPercent,
    required List<BudgetAllocation> allocations,
  }) async {
    final models = await _remoteDataSource.saveTarget(
      month: month,
      year: year,
      warningThresholdPercent: warningThresholdPercent,
      allocations: allocations,
    );
    return models.map((model) => model.toDomain()).toList(growable: false);
  }

  @override
  Future<MonthlyBudgetDetails> getMonthlyDetails({
    required int month,
    required int year,
  }) async {
    return (await _remoteDataSource.getMonthlyDetails(
      month: month,
      year: year,
    )).value;
  }

  @override
  Future<List<AnnualBudgetMonthSummary>> getAnnualSummary(int year) async {
    final models = await _remoteDataSource.getAnnualSummary(year);
    return models.map((model) => model.value).toList(growable: false);
  }
}
