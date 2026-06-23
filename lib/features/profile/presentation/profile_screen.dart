import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../routes/app_router.dart';
import '../../../core/widgets/glass_card.dart';

/// Profile & Settings screen — avatar, preferences, security, appearance, logout
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ref.read(profileRepositoryProvider).getProfile();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAccountSection(),
                  const SizedBox(height: 16),
                  _buildSecuritySection(),
                  const SizedBox(height: 16),
                  _buildAppearanceSection(),
                  const SizedBox(height: 16),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final name = _profileData?['fullName'] ??
        _profileData?['email']?.split('@')[0] ??
        'User';
    final email = _profileData?['email'] ?? '';
    final avatarInitials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                Theme.of(context).colorScheme.surfaceContainerLow,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          width: 3,
                        ),
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                      child: Center(
                        child: Text(
                          avatarInitials,
                          style: (Theme.of(context).textTheme.headlineMedium ??
                                  const TextStyle())
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: (Theme.of(context).textTheme.headlineMedium ??
                          const TextStyle())
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                Text(
                  email,
                  style: (Theme.of(context).textTheme.bodyMedium ??
                          const TextStyle())
                      .copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _SettingsSection(
      title: 'Account Preferences',
      children: [
        _SettingsTile(
          icon: Icons.person_outlined,
          label: 'Edit Profile',
          onTap: () async {
            final result = await context.push(AppRoutes.editProfile);
            if (result == true) _loadProfile();
          },
        ),
        _SettingsTile(
          icon: Icons.currency_exchange,
          label: 'Currency & Language',
          trailing: Text(
            '${_profileData?['currencyCode'] ?? 'USD'} • EN',
            style:
                (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
                    .copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: () async {
            final result = await context.push(AppRoutes.preferences);
            if (result == true) _loadProfile();
          },
        ),
        _SettingsTile(
          icon: Icons.notifications_outlined,
          label: 'Notification Settings',
          onTap: () => context.push(AppRoutes.notifications),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _SettingsSection(
      title: 'Security & Data',
      children: [
        _SettingsTile(
          icon: Icons.lock_outlined,
          label: 'Change Password',
          onTap: () => context.push(AppRoutes.changePassword),
        ),
        _SettingsTile(
          icon: Icons.fingerprint,
          label: 'Biometric Login',
          trailing: Switch(
            value: true,
            onChanged: (_) {},
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
          onTap: null,
        ),
        _SettingsTile(
          icon: Icons.cloud_upload_outlined,
          label: 'Export Data',
          onTap: () {},
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _SettingsSection(
      title: 'Appearance',
      children: [
        _SettingsTile(
          icon: Icons.palette_outlined,
          label: 'Theme',
          trailing: Text(
            'FlowFi default',
            style:
                (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
                    .copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: null,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'About',
      children: [
        _SettingsTile(
          icon: Icons.info_outlined,
          label: 'App Version',
          trailing: Text(
            '1.0.0',
            style:
                (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
                    .copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: null,
        ),
        _SettingsTile(
          icon: Icons.policy_outlined,
          label: 'Privacy Policy',
          onTap: () {},
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await ref.read(authRepositoryProvider).logout();
        } finally {
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style:
                  (Theme.of(context).textTheme.titleMedium ?? const TextStyle())
                      .copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
                .copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
                .copyWith(letterSpacing: 0.8),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: (Theme.of(context).textTheme.bodyMedium ??
                            const TextStyle())
                        .copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
