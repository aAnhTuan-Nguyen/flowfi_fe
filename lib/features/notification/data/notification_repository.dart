import '../../../core/network/dio_client.dart';

abstract interface class NotificationRepository {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _dioClient.dio.get('/notifications/notifications');
    final items = response.data['items'] as List;
    return items.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> markAsRead(String notificationId) =>
      _dioClient.dio.patch('/notifications/notifications/$notificationId/read');

  @override
  Future<void> markAllAsRead() =>
      _dioClient.dio.patch('/notifications/notifications/read-all');
}
