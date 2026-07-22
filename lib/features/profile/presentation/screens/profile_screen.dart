import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme_controller.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.account_circle_rounded,
      title: 'Hồ sơ cá nhân',
      subtitle: 'Quản lý thông tin tài khoản và thiết lập tiền tệ.',
      onRefresh: () async => ref.invalidate(authControllerProvider),
      child: SliverToBoxAdapter(
        child: auth.when(
          loading: () => const FlowFiInlineLoading(label: 'Đang tải hồ sơ'),
          error: (_, _) =>
              const FlowFiCard(child: Text('Không tải được hồ sơ.')),
          data: (state) => ProfileContent(user: state.user),
        ),
      ),
    );
  }
}

class ProfileContent extends ConsumerWidget {
  const ProfileContent({super.key, required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = _ProfileThemeChoice.fromThemeMode(
      ref.watch(appThemeModeProvider),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileEditForm(user: user),
        const SizedBox(height: 12),
        _ProfileSettingsCard(
          selectedTheme: selectedTheme,
          onThemeSelected: (choice) => ref
              .read(appThemeModeProvider.notifier)
              .setThemeMode(choice.themeMode),
        ),
        const SizedBox(height: 12),
        _ProfileLogoutButton(onPressed: () => _signOut(context, ref)),
        const SizedBox(height: 132),
      ],
    );
  }
}

class ProfileEditForm extends ConsumerStatefulWidget {
  const ProfileEditForm({super.key, required this.user});

  final AuthUser? user;

  @override
  ConsumerState<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _currencyCodeController;
  late final TextEditingController _monthlyBudgetLimitController;
  late final TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.user?.fullName ?? '',
    );
    _currencyCodeController = TextEditingController(
      text: widget.user?.currencyCode ?? 'VND',
    );
    _monthlyBudgetLimitController = TextEditingController(
      text: widget.user?.monthlyBudgetLimit ?? '',
    );
    _emailController = TextEditingController(
      text: widget.user?.email ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _currencyCodeController.dispose();
    _monthlyBudgetLimitController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _fullNameController.text.trim();
    final displayName = name.isEmpty ? 'Người dùng FlowFi' : name;
    final email = _emailController.text.trim().isEmpty
        ? 'Chưa có email'
        : _emailController.text.trim();

    return FlowFiCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ProfileSectionHeader(
              icon: Icons.person_rounded,
              title: 'Thông tin cá nhân',
              subtitle: 'Quản lý thông tin nhận diện tài khoản của bạn.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ProfileAvatar(name: displayName),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _ProfileEditIconButton(
                  onPressed: () => FocusScope.of(context).nextFocus(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            _ProfileTextField(
              label: 'Họ tên',
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _ProfileTextField(
              label: 'Email',
              controller: _emailController,
              readOnly: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _ProfileSaveButton(
              label: 'Lưu thông tin',
              onPressed: _isSaving ? null : _submit,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final fullName = _fullNameController.text.trim();
      final currencyCode = _currencyCodeController.text.trim().toUpperCase();
      final monthlyBudgetLimit = _monthlyBudgetLimitController.text.trim();
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(
            fullName: fullName.isEmpty ? null : fullName,
            currencyCode: currencyCode.isEmpty ? 'VND' : currencyCode,
            monthlyBudgetLimit: monthlyBudgetLimit.isEmpty
                ? null
                : monthlyBudgetLimit,
          );
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: colors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      image: true,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C8C3C), Color(0xFF37682B)],
          ),
        ),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 48),
      ),
    );
  }
}

class _ProfileEditIconButton extends StatelessWidget {
  const _ProfileEditIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(Icons.edit_outlined, color: colors.primary, size: 22),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.controller,
    this.textInputAction,
    this.readOnly = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            suffixIcon: Icon(
              Icons.edit_outlined,
              color: colors.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSaveButton extends StatelessWidget {
  const _ProfileSaveButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: enabled ? const Color(0xFF4F7C37) : colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 50,
          child: Center(
            child: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: enabled ? Colors.white : colors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: enabled
                                  ? Colors.white
                                  : colors.onSurfaceVariant,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSettingsCard extends StatelessWidget {
  const _ProfileSettingsCard({
    required this.selectedTheme,
    required this.onThemeSelected,
  });

  final _ProfileThemeChoice selectedTheme;
  final ValueChanged<_ProfileThemeChoice> onThemeSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProfileSectionHeader(
            icon: Icons.settings_rounded,
            title: 'Thiết lập',
            subtitle: 'Tùy chỉnh ứng dụng theo sở thích của bạn.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ProfileSoftIcon(
                      icon: Icons.palette_rounded,
                      size: 38,
                      iconSize: 21,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giao diện',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Chọn chế độ hiển thị phù hợp với bạn.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      for (final choice in _ProfileThemeChoice.values) ...[
                        Expanded(
                          child: _ProfileThemeSegment(
                            choice: choice,
                            selected: choice == selectedTheme,
                            onTap: () => onThemeSelected(choice),
                          ),
                        ),
                        if (choice != _ProfileThemeChoice.values.last)
                          Container(
                            width: 1,
                            height: 42,
                            color: colors.outlineVariant,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileThemeSegment extends StatelessWidget {
  const _ProfileThemeSegment({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final _ProfileThemeChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.primary : colors.onSurface;

    return Material(
      color: selected ? colors.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(choice.icon, color: foreground, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            choice.label,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: foreground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ThemeRadioIndicator(selected: selected, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ProfileThemeChoice {
  light(
    label: 'Chế độ sáng',
    icon: Icons.light_mode_outlined,
    themeMode: ThemeMode.light,
  ),
  dark(
    label: 'Chế độ tối',
    icon: Icons.dark_mode_outlined,
    themeMode: ThemeMode.dark,
  ),
  system(
    label: 'Theo hệ thống',
    icon: Icons.desktop_windows_outlined,
    themeMode: ThemeMode.system,
  );

  const _ProfileThemeChoice({
    required this.label,
    required this.icon,
    required this.themeMode,
  });

  final String label;
  final IconData icon;
  final ThemeMode themeMode;

  static _ProfileThemeChoice fromThemeMode(ThemeMode mode) {
    return _ProfileThemeChoice.values.firstWhere(
      (choice) => choice.themeMode == mode,
      orElse: () => _ProfileThemeChoice.light,
    );
  }
}

class _ProfileLogoutButton extends StatelessWidget {
  const _ProfileLogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: colors.onSurface, size: 20),
              const SizedBox(width: 9),
              Text(
                'Đăng xuất',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeRadioIndicator extends StatelessWidget {
  const _ThemeRadioIndicator({required this.selected, this.size = 24});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.primary : colors.onSurfaceVariant,
          width: selected ? 2.2 : 1.7,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: size / 2,
                height: size / 2,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _ProfileSoftIcon extends StatelessWidget {
  const _ProfileSoftIcon({
    required this.icon,
    this.size = 46,
    this.iconSize = 22,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: colors.onSurface, size: iconSize),
    );
  }
}

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final confirmed = await confirmDestructiveAction(
    context,
    title: 'Đăng xuất?',
    message: 'Bạn cần đăng nhập lại để tiếp tục dùng FlowFi.',
    actionLabel: 'Đăng xuất',
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  try {
    await ref.read(authControllerProvider.notifier).signOut();
  } catch (_) {
    if (context.mounted) {
      showGenericMutationError(context);
    }
  }
}
