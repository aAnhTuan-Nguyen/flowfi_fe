enum AppNotificationType {
  budgetWarning,
  goalReminder,
  system,
  transaction,
  unknown,
}

final class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    this.content,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? content;
  final AppNotificationType type;
  final bool isRead;
  final DateTime? createdAt;
}

AppNotificationType appNotificationTypeFromApi(Object? value) {
  return switch (value) {
    'BudgetWarning' => AppNotificationType.budgetWarning,
    'GoalReminder' => AppNotificationType.goalReminder,
    'System' => AppNotificationType.system,
    'Transaction' => AppNotificationType.transaction,
    _ => AppNotificationType.unknown,
  };
}
