import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';

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
    final colors = Theme.of(context).colorScheme;
    final name = user?.fullName?.trim();
    final displayName = name == null || name.isEmpty
        ? 'Người dùng FlowFi'
        : name;
    final email = user?.email ?? 'Chưa có email';
    final currency = user?.currencyCode ?? 'VND';
    final budget = user?.monthlyBudgetLimit ?? 'Chưa đặt';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        ProfileEditForm(user: user),
        const SizedBox(height: 14),
        FlowFiButton(
          label: 'Đăng xuất',
          icon: Icons.logout_rounded,
          variant: FlowFiButtonVariant.outline,
          onPressed: () => _signOut(context, ref),
        ),
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
    return FlowFiCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chỉnh sửa hồ sơ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FlowFiTextField(
              label: 'Họ tên',
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
            ),
            FlowFiTextField(
              label: 'Email',
              controller: _emailController,
              enabled: false,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            FlowFiTextField(
              label: 'Tiền tệ',
              controller: _currencyCodeController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              enabled: false,
              validator: (value) {
                final normalized = value?.trim();
                if (normalized == null || normalized.isEmpty) {
                  return 'Nhập mã tiền tệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            FlowFiTextField(
              label: 'Hạn mức tháng',
              controller: _monthlyBudgetLimitController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 18),
            FlowFiButton(
              label: 'Lưu hồ sơ',
              onPressed: _isSaving ? null : _submit,
              isLoading: _isSaving,
              icon: Icons.check_rounded,
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

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'F';
  }
  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
