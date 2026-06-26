import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/domain/entities/app_notification.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.insights_rounded,
      title: 'Insights',
      subtitle: 'Notifications and backend-driven insights.',
      onRefresh: () => ref.read(notificationsProvider.notifier).reload(),
      actions: [
        IconButton.filled(
          onPressed: () async {
            try {
              await ref.read(notificationsProvider.notifier).markAllRead();
            } catch (_) {
              if (context.mounted) {
                showGenericMutationError(context);
              }
            }
          },
          icon: const Icon(Icons.done_all_rounded),
          tooltip: 'Mark all read',
        ),
      ],
      child: notifications.when(
        loading: () => const _LoadingState(),
        error: (_, _) => FlowFiErrorState(
          onRetry: () => ref.read(notificationsProvider.notifier).reload(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const FlowFiEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              message: 'Budget warnings and goal reminders will appear here.',
            );
          }
          return separatedSliverList(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _NotificationCard(notification: items[index]);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlowFiCard(
      color: notification.isRead ? Colors.white : const Color(0xFFFFF6EB),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F1DA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _notificationIcon(notification.type),
              color: const Color(0xFF49672A),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (notification.content != null &&
                    notification.content!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.content!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF757872),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<_NotificationAction>(
            tooltip: 'Notification actions',
            onSelected: (action) async {
              switch (action) {
                case _NotificationAction.read:
                  try {
                    await ref
                        .read(notificationsProvider.notifier)
                        .markRead(notification.id);
                  } catch (_) {
                    if (context.mounted) {
                      showGenericMutationError(context);
                    }
                  }
                case _NotificationAction.delete:
                  final confirmed = await confirmDestructiveAction(
                    context,
                    title: 'Delete notification?',
                    message: 'This removes the notification from FlowFi.',
                  );
                  if (confirmed) {
                    try {
                      await ref
                          .read(notificationsProvider.notifier)
                          .deleteNotification(notification.id);
                    } catch (_) {
                      if (context.mounted) {
                        showGenericMutationError(context);
                      }
                    }
                  }
              }
            },
            itemBuilder: (context) => [
              if (!notification.isRead)
                const PopupMenuItem(
                  value: _NotificationAction.read,
                  child: Text('Mark read'),
                ),
              const PopupMenuItem(
                value: _NotificationAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _NotificationAction { read, delete }

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

IconData _notificationIcon(AppNotificationType type) {
  return switch (type) {
    AppNotificationType.budgetWarning => Icons.warning_amber_rounded,
    AppNotificationType.goalReminder => Icons.flag_rounded,
    AppNotificationType.system => Icons.auto_awesome_rounded,
    AppNotificationType.transaction => Icons.receipt_long_rounded,
    AppNotificationType.unknown => Icons.notifications_rounded,
  };
}
