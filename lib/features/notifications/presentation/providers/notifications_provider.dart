import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => serviceLocator<NotificationRepository>(),
);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  Timer? _pollingTimer;

  @override
  Future<List<AppNotification>> build() async {
    ref.onDispose(() {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    });
    _startPolling();
    final all = await ref.watch(notificationRepositoryProvider).listNotifications();
    return _mergeBalanceNotifications(all);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _silentRefresh(),
    );
  }

  Future<void> _silentRefresh() async {
    try {
      final fresh = await ref
          .read(notificationRepositoryProvider)
          .listNotifications();
      state = AsyncData(_mergeBalanceNotifications(fresh));
    } catch (_) {
      // Ignore polling errors; keep last known state.
    }
  }

  List<AppNotification> _mergeBalanceNotifications(List<AppNotification> all) {
    final List<AppNotification> merged = [];
    
    // Sort by createdAt descending so newest is first (standard for notifications)
    final sorted = all.toList()..sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    
    for (int i = 0; i < sorted.length; i++) {
      final current = sorted[i];
      if (current.title.startsWith('Số dư ví') || (current.title.startsWith('S') && current.title.contains('hiện tại'))) {
        // Skip balance notifications as they will be merged or ignored
        continue;
      }
      
      // Look for a balance notification around the same time (adjacent)
      AppNotification? relatedBalance;
      for (int j = i - 1; j >= 0 && j >= i - 3; j--) {
        if (sorted[j].title.startsWith('Số dư ví') || (sorted[j].title.startsWith('S') && sorted[j].title.contains('hiện tại'))) {
          relatedBalance = sorted[j];
          break;
        }
      }
      if (relatedBalance == null) {
        for (int j = i + 1; j < sorted.length && j <= i + 3; j++) {
          if (sorted[j].title.startsWith('Số dư ví') || (sorted[j].title.startsWith('S') && sorted[j].title.contains('hiện tại'))) {
            relatedBalance = sorted[j];
            break;
          }
        }
      }

      if (relatedBalance != null) {
        // Create a new notification with merged content
        merged.add(AppNotification(
          id: current.id,
          title: current.title,
          content: '${current.content ?? ''}\n\n${relatedBalance.content ?? ''}'.trim(),
          type: current.type,
          isRead: current.isRead,
          createdAt: current.createdAt,
        ));
      } else {
        merged.add(current);
      }
    }
    
    return merged;
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    await reload();
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRepositoryProvider).markRead(id);
    await reload();
  }

  Future<void> deleteNotification(String id) async {
    await ref.read(notificationRepositoryProvider).deleteNotification(id);
    await reload();
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );
