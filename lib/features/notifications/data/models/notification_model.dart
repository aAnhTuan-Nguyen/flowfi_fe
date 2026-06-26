import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/app_notification.dart';

final class NotificationModel {
  const NotificationModel({
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

  factory NotificationModel.fromJson(JsonMap json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString(),
      type: appNotificationTypeFromApi(json['notificationType']),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  AppNotification toDomain() {
    return AppNotification(
      id: id,
      title: title,
      content: content,
      type: type,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}
