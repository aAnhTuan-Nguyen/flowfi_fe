import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../models/budget_model.dart';
import '../models/monthly_budget_details_model.dart';
import '../models/annual_budget_summary_model.dart';
import '../../domain/entities/budget.dart';

abstract interface class BudgetRemoteDataSource {
  Future<List<BudgetModel>> listBudgets({int page = 1, int limit = 20});

  Future<BudgetModel> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  });

  Future<BudgetModel> updateBudget(
    String id, {
    String? tagId,
    String? amount,
    int? month,
    int? year,
    int? warningThresholdPercent,
  });

  Future<void> deleteBudget(String id);

  Future<List<BudgetModel>> saveTarget({
    required int month,
    required int year,
    required int warningThresholdPercent,
    required List<BudgetAllocation> allocations,
  });

  Future<MonthlyBudgetDetailsModel> getMonthlyDetails({
    required int month,
    required int year,
  });

  Future<List<AnnualBudgetMonthSummaryModel>> getAnnualSummary(int year);
}

final class DioBudgetRemoteDataSource implements BudgetRemoteDataSource {
  DioBudgetRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<BudgetModel>> listBudgets({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Object?>(
      'budgets',
      queryParameters: {'page': page, 'limit': limit},
    );
    return readApiList(response.data).map(BudgetModel.fromJson).toList();
  }

  @override
  Future<BudgetModel> createBudget({
    String? tagId,
    required String amount,
    required int month,
    required int year,
    required int warningThresholdPercent,
  }) async {
    final data = <String, Object?>{
      'tagId': tagId,
      'budgetAmount': amount,
      'month': month,
      'year': year,
      'warningThresholdPercent': warningThresholdPercent,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.post<Object?>('budgets', data: data);
    return BudgetModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<BudgetModel> updateBudget(
    String id, {
    String? tagId,
    String? amount,
    int? month,
    int? year,
    int? warningThresholdPercent,
  }) async {
    final data = <String, Object?>{
      'tagId': tagId,
      'budgetAmount': amount,
      'month': month,
      'year': year,
      'warningThresholdPercent': warningThresholdPercent,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.patch<Object?>('budgets/$id', data: data);
    return BudgetModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _dio.delete<void>('budgets/$id');
  }

  @override
  Future<List<BudgetModel>> saveTarget({
    required int month,
    required int year,
    required int warningThresholdPercent,
    required List<BudgetAllocation> allocations,
  }) async {
    final response = await _dio.put<Object?>(
      'budgets/target',
      data: {
        'month': month,
        'year': year,
        'warningThresholdPercent': warningThresholdPercent,
        'allocations': [
          for (final allocation in allocations)
            {'tagId': allocation.tagId, 'amount': allocation.amount},
        ],
      },
    );
    return readApiList(response.data).map(BudgetModel.fromJson).toList();
  }

  @override
  Future<MonthlyBudgetDetailsModel> getMonthlyDetails({
    required int month,
    required int year,
  }) async {
    final response = await _dio.get<Object?>(
      'budgets/monthly-details',
      queryParameters: {'month': month, 'year': year},
    );
    return MonthlyBudgetDetailsModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<List<AnnualBudgetMonthSummaryModel>> getAnnualSummary(int year) async {
    final response = await _dio.get<Object?>(
      'budgets/annual-summary',
      queryParameters: {'year': year},
    );
    return readApiList(
      response.data,
    ).map(AnnualBudgetMonthSummaryModel.fromJson).toList(growable: false);
  }
}
