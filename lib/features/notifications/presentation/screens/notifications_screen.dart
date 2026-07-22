import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_notification.dart';

import '../../../shared/presentation/widgets/feature_states.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllRead();
            },
            child: const Text('Đánh dấu đã đọc'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: FlowFiInlineLoading(label: 'Đang tải thông báo'),
        ),
        error: (error, stack) => Center(
          child: FlowFiCard(child: Text('Không tải được thông báo: $error')),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('Bạn chưa có thông báo nào.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).reload(),
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  tileColor: notification.isRead
                      ? null
                      : Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.3),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      _getIconForType(notification.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notification.content ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        notification.createdAt?.toString().substring(0, 16) ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!notification.isRead) {
                      ref
                          .read(notificationsProvider.notifier)
                          .markRead(notification.id);
                    }
                    // TODO: Handle navigation based on notificationType and metadata if needed
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.transaction:
        return Icons.receipt;
      case AppNotificationType.budgetWarning:
        return Icons.warning_amber_rounded;
      case AppNotificationType.goalReminder:
        return Icons.calendar_today_rounded;
      case AppNotificationType.system:
      default:
        return Icons.info_outline;
    }
  }
}
