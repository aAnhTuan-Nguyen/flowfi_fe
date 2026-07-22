class NotificationPreference {
  const NotificationPreference({
    required this.transactionNotifications,
    required this.budgetWarning,
    required this.dailyReminder,
    required this.dailyReminderHour,
    required this.weeklySummary,
    required this.monthlySummary,
    required this.savingsTip,
    required this.timezone,
  });

  final bool transactionNotifications;
  final bool budgetWarning;
  final bool dailyReminder;
  final int dailyReminderHour;
  final bool weeklySummary;
  final bool monthlySummary;
  final bool savingsTip;
  final String timezone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreference &&
          runtimeType == other.runtimeType &&
          transactionNotifications == other.transactionNotifications &&
          budgetWarning == other.budgetWarning &&
          dailyReminder == other.dailyReminder &&
          dailyReminderHour == other.dailyReminderHour &&
          weeklySummary == other.weeklySummary &&
          monthlySummary == other.monthlySummary &&
          savingsTip == other.savingsTip &&
          timezone == other.timezone;

  @override
  int get hashCode => Object.hash(
        transactionNotifications,
        budgetWarning,
        dailyReminder,
        dailyReminderHour,
        weeklySummary,
        monthlySummary,
        savingsTip,
        timezone,
      );

  NotificationPreference copyWith({
    bool? transactionNotifications,
    bool? budgetWarning,
    bool? dailyReminder,
    int? dailyReminderHour,
    bool? weeklySummary,
    bool? monthlySummary,
    bool? savingsTip,
    String? timezone,
  }) {
    return NotificationPreference(
      transactionNotifications:
          transactionNotifications ?? this.transactionNotifications,
      budgetWarning: budgetWarning ?? this.budgetWarning,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      savingsTip: savingsTip ?? this.savingsTip,
      timezone: timezone ?? this.timezone,
    );
  }
}
