import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../domain/entities/notification_preference.dart';
import '../providers/notification_preferences_provider.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
      ),
      body: preferencesAsync.when(
        loading: () => const Center(
          child: FlowFiInlineLoading(label: 'Đang tải cài đặt'),
        ),
        error: (error, stack) => Center(
          child: FlowFiCard(child: Text('Không tải được cài đặt: $error')),
        ),
        data: (preferences) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPreferenceSwitch(
                  context,
                  ref,
                  title: 'Cảnh báo ngân sách',
                  subtitle: 'Nhận cảnh báo khi sắp vượt ngân sách',
                  value: preferences.budgetWarning,
                  onChanged: (val) {
                    _updatePreference(
                      context,
                      ref,
                      preferences.copyWith(budgetWarning: val),
                    );
                  },
                ),
                _buildPreferenceSwitch(
                  context,
                  ref,
                  title: 'Nhắc nhở hàng ngày',
                  subtitle: 'Nhắc nhở ghi chép chi tiêu mỗi ngày',
                  value: preferences.dailyReminder,
                  onChanged: (val) {
                    _updatePreference(
                      context,
                      ref,
                      preferences.copyWith(dailyReminder: val),
                    );
                  },
                ),
                if (preferences.dailyReminder)
                  _buildTimePickerTile(
                    context,
                    ref,
                    title: 'Giờ nhắc nhở hàng ngày',
                    subtitle: '${preferences.dailyReminderHour}:00',
                    currentHour: preferences.dailyReminderHour,
                    onHourChanged: (val) {
                      _updatePreference(
                        context,
                        ref,
                        preferences.copyWith(dailyReminderHour: val),
                      );
                    },
                  ),
                _buildPreferenceSwitch(
                  context,
                  ref,
                  title: 'Tóm tắt hàng tuần',
                  subtitle: 'Nhận báo cáo tổng quan mỗi tuần',
                  value: preferences.weeklySummary,
                  onChanged: (val) {
                    _updatePreference(
                      context,
                      ref,
                      preferences.copyWith(weeklySummary: val),
                    );
                  },
                ),
                _buildPreferenceSwitch(
                  context,
                  ref,
                  title: 'Tóm tắt hàng tháng',
                  subtitle: 'Nhận báo cáo tổng quan mỗi tháng',
                  value: preferences.monthlySummary,
                  onChanged: (val) {
                    _updatePreference(
                      context,
                      ref,
                      preferences.copyWith(monthlySummary: val),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreferenceSwitch(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return FSwitch(
      value: value,
      onChange: onChanged,
      label: Text(title),
      description: Text(subtitle),
    );
  }

  Widget _buildTimePickerTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required int currentHour,
    required ValueChanged<int> onHourChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: currentHour, minute: 0),
        );
        if (time != null) {
          onHourChanged(time.hour);
        }
      },
    );
  }

  Future<void> _updatePreference(
    BuildContext context,
    WidgetRef ref,
    NotificationPreference updated,
  ) async {
    try {
      await ref
          .read(notificationPreferencesProvider.notifier)
          .updatePreferences(updated);
    } catch (e) {
      if (context.mounted) {
        showGenericMutationError(context);
      }
    }
  }
}
