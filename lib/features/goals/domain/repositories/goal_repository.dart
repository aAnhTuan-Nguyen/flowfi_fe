import '../entities/goal.dart';

abstract interface class GoalRepository {
  Future<List<Goal>> listGoals({int page = 1, int limit = 20});

  Future<Goal> createGoal({
    String? walletId,
    required String name,
    String? description,
    required String targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus status = GoalStatus.active,
  });

  Future<Goal> updateGoal(
    String id, {
    String? walletId,
    String? name,
    String? description,
    String? targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus? status,
  });

  Future<Goal> updateGoalProgress(String id, {required String currentAmount});

  Future<void> deleteGoal(String id);
}
