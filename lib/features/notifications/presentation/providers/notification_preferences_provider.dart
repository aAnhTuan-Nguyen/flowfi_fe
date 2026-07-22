import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_preference.dart';
import 'notifications_provider.dart';

class NotificationPreferencesNotifier
    extends AsyncNotifier<NotificationPreference> {
  @override
  Future<NotificationPreference> build() {
    return ref.watch(notificationRepositoryProvider).getPreferences();
  }

  Future<void> updatePreferences(NotificationPreference preference) async {
    final previousState = state;
    state = const AsyncLoading();
    try {
      final updated = await ref
          .read(notificationRepositoryProvider)
          .updatePreferences(preference);
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
      // Revert on error
      if (previousState.hasValue) {
        state = previousState;
      }
      rethrow;
    }
  }
}

final notificationPreferencesProvider = AsyncNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreference>(
  NotificationPreferencesNotifier.new,
);
