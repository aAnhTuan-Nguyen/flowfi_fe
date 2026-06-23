import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';

/// FlowFi top app bar — glassmorphic sticky header
/// Used in all main-tab screens and sub-screens
class FlowFiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FlowFiAppBar({
    super.key,
    this.title = 'FlowFi',
    this.showBack = false,
    this.showAvatar = true,
    this.avatarUrl,
    this.userName,
    this.actions,
  });

  final String title;
  final bool showBack;
  final bool showAvatar;
  final String? avatarUrl;
  final String? userName;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: preferredSize.height + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                )
              else if (showAvatar)
                _buildAvatar(context),
              const SizedBox(width: 12),
              if (userName != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: (Theme.of(context).textTheme.labelSmall ??
                                const TextStyle())
                            .copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Hi, $userName',
                        style: (Theme.of(context).textTheme.headlineMedium ??
                                const TextStyle())
                            .copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Text(
                    title,
                    style: (Theme.of(context).textTheme.headlineMedium ??
                            const TextStyle())
                        .copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              if (actions != null)
                ...actions!
              else
                _buildNotificationButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultAvatar(context),
              )
            : _defaultAvatar(context),
      ),
    );
  }

  Widget _defaultAvatar(BuildContext context) {
    return Container(
      color:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.primary,
        size: 22,
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.notifications),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ),
    );
  }
}
