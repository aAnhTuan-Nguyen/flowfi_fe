import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preference.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_preference_model.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<AppNotification>> listNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final models = await _remoteDataSource.listNotifications(
      page: page,
      limit: limit,
    );
    return models.map((model) => model.toDomain()).toList(growable: false);
  }

  @override
  Future<void> markAllRead() {
    return _remoteDataSource.markAllRead();
  }

  @override
  Future<void> markRead(String id) {
    return _remoteDataSource.markRead(id);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _remoteDataSource.deleteNotification(id);
  }

  @override
  Future<NotificationPreference> getPreferences() async {
    return _remoteDataSource.getPreferences();
  }

  @override
  Future<NotificationPreference> updatePreferences(
    NotificationPreference preference,
  ) async {
    final model = NotificationPreferenceModel.fromEntity(preference);
    return _remoteDataSource.updatePreferences(model);
  }
}
