import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../models/budget_model.dart';

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
}
