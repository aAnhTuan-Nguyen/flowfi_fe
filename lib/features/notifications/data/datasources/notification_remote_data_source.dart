import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> listNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<void> markAllRead();

  Future<void> markRead(String id);

  Future<void> deleteNotification(String id);
}

final class DioNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  DioNotificationRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<NotificationModel>> listNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Object?>(
      'notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    return readApiList(response.data).map(NotificationModel.fromJson).toList();
  }

  @override
  Future<void> markAllRead() async {
    await _dio.patch<void>('notifications/read-all');
  }

  @override
  Future<void> markRead(String id) async {
    await _dio.patch<void>('notifications/$id/read');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _dio.delete<void>('notifications/$id');
  }
}
