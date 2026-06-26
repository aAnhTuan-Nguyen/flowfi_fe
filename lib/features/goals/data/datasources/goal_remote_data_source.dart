import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/goal.dart';
import '../models/goal_model.dart';

abstract interface class GoalRemoteDataSource {
  Future<List<GoalModel>> listGoals({int page = 1, int limit = 20});

  Future<GoalModel> createGoal({
    String? walletId,
    required String name,
    String? description,
    required String targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus status = GoalStatus.active,
  });

  Future<GoalModel> updateGoal(
    String id, {
    String? walletId,
    String? name,
    String? description,
    String? targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus? status,
  });

  Future<GoalModel> updateGoalProgress(
    String id, {
    required String currentAmount,
  });

  Future<void> deleteGoal(String id);
}

final class DioGoalRemoteDataSource implements GoalRemoteDataSource {
  DioGoalRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<GoalModel>> listGoals({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Object?>(
      'goals',
      queryParameters: {'page': page, 'limit': limit},
    );
    return readApiList(response.data).map(GoalModel.fromJson).toList();
  }

  @override
  Future<GoalModel> createGoal({
    String? walletId,
    required String name,
    String? description,
    required String targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus status = GoalStatus.active,
  }) async {
    final data = <String, Object?>{
      'walletId': walletId,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'status': status.apiValue,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.post<Object?>('goals', data: data);
    return GoalModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<GoalModel> updateGoal(
    String id, {
    String? walletId,
    String? name,
    String? description,
    String? targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus? status,
  }) async {
    final data = <String, Object?>{
      'walletId': walletId,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'status': status?.apiValue,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.patch<Object?>('goals/$id', data: data);
    return GoalModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<GoalModel> updateGoalProgress(
    String id, {
    required String currentAmount,
  }) async {
    final response = await _dio.patch<Object?>(
      'goals/$id/progress',
      data: {'currentAmount': currentAmount},
    );
    return GoalModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _dio.delete<void>('goals/$id');
  }
}
