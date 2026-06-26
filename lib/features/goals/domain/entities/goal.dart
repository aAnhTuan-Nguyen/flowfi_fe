enum GoalStatus { active, completed, cancelled, unknown }

extension GoalStatusApi on GoalStatus {
  String get apiValue {
    return switch (this) {
      GoalStatus.active => 'Active',
      GoalStatus.completed => 'Completed',
      GoalStatus.cancelled => 'Cancelled',
      GoalStatus.unknown => 'Unknown',
    };
  }
}

final class Goal {
  const Goal({
    required this.id,
    this.walletId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.status,
  });

  final String id;
  final String? walletId;
  final String name;
  final String? description;
  final String targetAmount;
  final String currentAmount;
  final DateTime? deadline;
  final GoalStatus status;
}

GoalStatus goalStatusFromApi(Object? value) {
  return switch (value) {
    'Active' => GoalStatus.active,
    'Completed' => GoalStatus.completed,
    'Cancelled' => GoalStatus.cancelled,
    _ => GoalStatus.unknown,
  };
}
