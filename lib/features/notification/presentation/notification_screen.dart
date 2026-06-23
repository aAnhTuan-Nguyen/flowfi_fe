import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/notification_tile.dart';

/// Notification Center screen — filter chips + grouped notification list
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  int _selectedFilter = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  static const _filters = ['All', 'Budget', 'Goals', 'Reports', 'System'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final notifications = await repo.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: context.colors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headlineMd(color: context.colors.primary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMd(color: context.colors.secondary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final isSelected = i == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outlineVariant,
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: AppTextStyles.labelMd(
                          color: isSelected
                              ? context.colors.onPrimary
                              : context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: _notifications.isEmpty
                        ? const Center(child: Text('No notifications found.'))
                        : ListView(
                            children: _notifications.map((n) {
                              return Column(
                                children: [
                                  NotificationTile(
                                    title: n['title'] ?? 'Notification',
                                    body: n['message'] ?? '',
                                    timeAgo: n['createdAt'] ?? 'Recently',
                                    iconData: Icons.notifications_active,
                                    iconBgColor: context.colors.primaryContainer.withValues(alpha: 0.2),
                                    iconColor: context.colors.primary,
                                    isUnread: !(n['isRead'] ?? false),
                                  ),
                                  Divider(height: 1, color: context.colors.surfaceContainerLow),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
