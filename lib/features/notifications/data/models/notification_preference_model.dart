import '../../domain/entities/notification_preference.dart';

class NotificationPreferenceModel extends NotificationPreference {
  const NotificationPreferenceModel({
    required super.transactionNotifications,
    required super.budgetWarning,
    required super.dailyReminder,
    required super.dailyReminderHour,
    required super.weeklySummary,
    required super.monthlySummary,
    required super.savingsTip,
    required super.timezone,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      transactionNotifications: json['transactionNotifications'] as bool? ?? true,
      budgetWarning: json['budgetWarning'] as bool? ?? true,
      dailyReminder: json['dailyReminder'] as bool? ?? true,
      dailyReminderHour: json['dailyReminderHour'] as int? ?? 20,
      weeklySummary: json['weeklySummary'] as bool? ?? true,
      monthlySummary: json['monthlySummary'] as bool? ?? true,
      savingsTip: json['savingsTip'] as bool? ?? true,
      timezone: json['timezone'] as String? ?? 'Asia/Ho_Chi_Minh',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionNotifications': transactionNotifications,
      'budgetWarning': budgetWarning,
      'dailyReminder': dailyReminder,
      'dailyReminderHour': dailyReminderHour,
      'weeklySummary': weeklySummary,
      'monthlySummary': monthlySummary,
      'savingsTip': savingsTip,
      'timezone': timezone,
    };
  }

  factory NotificationPreferenceModel.fromEntity(NotificationPreference entity) {
    return NotificationPreferenceModel(
      transactionNotifications: entity.transactionNotifications,
      budgetWarning: entity.budgetWarning,
      dailyReminder: entity.dailyReminder,
      dailyReminderHour: entity.dailyReminderHour,
      weeklySummary: entity.weeklySummary,
      monthlySummary: entity.monthlySummary,
      savingsTip: entity.savingsTip,
      timezone: entity.timezone,
    );
  }
}
