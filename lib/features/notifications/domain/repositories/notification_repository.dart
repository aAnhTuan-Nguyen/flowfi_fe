import '../entities/app_notification.dart';
import '../entities/notification_preference.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> listNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<void> markAllRead();

  Future<void> markRead(String id);

  Future<void> deleteNotification(String id);

  Future<NotificationPreference> getPreferences();

  Future<NotificationPreference> updatePreferences(
    NotificationPreference preference,
  );
}
