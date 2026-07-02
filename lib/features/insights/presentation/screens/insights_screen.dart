import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/domain/entities/app_notification.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.insights_rounded,
      title: 'Thông báo',
      subtitle: 'Thông báo và gợi ý từ hệ thống.',
      onRefresh: () => ref.read(notificationsProvider.notifier).reload(),
      actions: [
        FlowFiIconButton(
          onPressed: () async {
            try {
              await ref.read(notificationsProvider.notifier).markAllRead();
            } catch (_) {
              if (context.mounted) {
                showGenericMutationError(context);
              }
            }
          },
          icon: Icons.done_all_rounded,
          tooltip: 'Đánh dấu tất cả đã đọc',
          variant: FlowFiButtonVariant.primary,
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
              title: 'Chưa có thông báo',
              message:
                  'Cảnh báo ngân sách và nhắc mục tiêu sẽ xuất hiện tại đây.',
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
    final content = notification.content;
    final colors = Theme.of(context).colorScheme;

    return FlowFiListItemCard(
      icon: _notificationIcon(notification.type),
      tone: notification.isRead ? FlowFiTone.neutral : FlowFiTone.info,
      color: notification.isRead ? colors.surface : colors.surfaceContainerLow,
      title: notification.title,
      subtitle: content == null || content.isEmpty
          ? 'Không có nội dung'
          : content,
      status: notification.isRead
          ? null
          : const FlowFiStatusBadge(label: 'Mới', tone: FlowFiTone.info),
      action: FlowFiActionMenu(
        tooltip: 'Tùy chọn thông báo',
        actions: [
          if (!notification.isRead)
            FlowFiMenuAction(
              label: 'Đánh dấu đã đọc',
              icon: Icons.done_rounded,
              onSelected: () => _markRead(context, ref),
            ),
          FlowFiMenuAction(
            label: 'Xóa',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onSelected: () => _delete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _markRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(notificationsProvider.notifier).markRead(notification.id);
    } catch (_) {
      if (context.mounted) {
        showGenericMutationError(context);
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Xóa thông báo?',
      message: 'Thông báo này sẽ bị xóa khỏi FlowFi.',
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
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const FlowFiSliverLoading(label: 'Đang tải thông báo');
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
