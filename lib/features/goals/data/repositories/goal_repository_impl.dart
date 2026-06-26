import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_remote_data_source.dart';

final class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._remoteDataSource);

  final GoalRemoteDataSource _remoteDataSource;

  @override
  Future<List<Goal>> listGoals({int page = 1, int limit = 20}) async {
    final models = await _remoteDataSource.listGoals(page: page, limit: limit);
    return models.map((model) => model.toDomain()).toList(growable: false);
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
    return (await _remoteDataSource.createGoal(
      walletId: walletId,
      name: name,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      status: status,
    )).toDomain();
  }

  @override
  Future<void> deleteGoal(String id) {
    return _remoteDataSource.deleteGoal(id);
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
    return (await _remoteDataSource.updateGoal(
      id,
      walletId: walletId,
      name: name,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      status: status,
    )).toDomain();
  }

  @override
  Future<Goal> updateGoalProgress(
    String id, {
    required String currentAmount,
  }) async {
    return (await _remoteDataSource.updateGoalProgress(
      id,
      currentAmount: currentAmount,
    )).toDomain();
  }
}
