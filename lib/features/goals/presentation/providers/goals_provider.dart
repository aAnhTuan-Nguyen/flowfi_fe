import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => serviceLocator<GoalRepository>(),
);

class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() {
    return ref.watch(goalRepositoryProvider).listGoals();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createGoal({
    String? walletId,
    required String name,
    String? description,
    required String targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus status = GoalStatus.active,
  }) async {
    await ref
        .read(goalRepositoryProvider)
        .createGoal(
          walletId: walletId,
          name: name,
          description: description,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          deadline: deadline,
          status: status,
        );
    await reload();
  }

  Future<void> updateGoal(
    String id, {
    String? walletId,
    String? name,
    String? description,
    String? targetAmount,
    String? currentAmount,
    DateTime? deadline,
    GoalStatus? status,
  }) async {
    await ref
        .read(goalRepositoryProvider)
        .updateGoal(
          id,
          walletId: walletId,
          name: name,
          description: description,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          deadline: deadline,
          status: status,
        );
    await reload();
  }

  Future<void> updateGoalProgress(
    String id, {
    required String currentAmount,
  }) async {
    await ref
        .read(goalRepositoryProvider)
        .updateGoalProgress(id, currentAmount: currentAmount);
    await reload();
  }

  Future<void> deleteGoal(String id) async {
    await ref.read(goalRepositoryProvider).deleteGoal(id);
    await reload();
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);
