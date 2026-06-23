import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
          height: preferredSize.height +
              MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.85),
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
                      color: context.colors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: context.colors.primary,
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
                        style: AppTextStyles.labelSm(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Hi, $userName',
                        style: AppTextStyles.headlineLgMobile(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineMd(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              if (actions != null) ...actions!
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
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        color: context.colors.surfaceContainerLow,
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
      color: context.colors.primaryContainer.withValues(alpha: 0.3),
      child: Icon(
        Icons.person,
        color: context.colors.primary,
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
          color: context.colors.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_outlined,
          color: context.colors.primary,
          size: 22,
        ),
      ),
    );
  }
}
