import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> listNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<void> markAllRead();

  Future<void> markRead(String id);

  Future<void> deleteNotification(String id);

  Future<NotificationPreferenceModel> getPreferences();

  Future<NotificationPreferenceModel> updatePreferences(
    NotificationPreferenceModel preference,
  );
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

  @override
  Future<NotificationPreferenceModel> getPreferences() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'notifications/preferences',
    );
    return NotificationPreferenceModel.fromJson(response.data!);
  }

  @override
  Future<NotificationPreferenceModel> updatePreferences(
    NotificationPreferenceModel preference,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      'notifications/preferences',
      data: preference.toJson(),
    );
    return NotificationPreferenceModel.fromJson(response.data!);
  }
}
