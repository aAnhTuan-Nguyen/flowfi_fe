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
  Future<List<AppNotification>> build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    });
    _startPolling();
    return ref.watch(notificationRepositoryProvider).listNotifications();
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
      state = AsyncData(fresh);
    } catch (_) {
      // Ignore polling errors; keep last known state.
    }
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
