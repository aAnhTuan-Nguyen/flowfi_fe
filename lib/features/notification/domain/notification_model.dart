import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      body: json['content'] as String? ?? '', // Maps from BE Content
      type: json['notificationType'] as String? ?? 'system', // Maps from BE NotificationType
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['targetUrl'] as String?, // Maps from BE TargetUrl
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': body,
      'notificationType': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      if (actionUrl != null) 'targetUrl': actionUrl,
    };
  }

  @override
  List<Object?> get props => [id, title, body, type, createdAt, isRead, actionUrl];
}
