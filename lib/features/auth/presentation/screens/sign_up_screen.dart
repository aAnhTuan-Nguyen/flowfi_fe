import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../providers/auth_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authValue = ref.watch(authControllerProvider);
    final isLoading = authValue.isLoading;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'FlowFi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      FlowFiIconButton(
                        tooltip: 'Quay lại đăng nhập',
                        onPressed: isLoading ? null : _returnToSignIn,
                        icon: Icons.arrow_back_rounded,
                        variant: FlowFiButtonVariant.ghost,
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  FlowFiCard(
                    padding: const EdgeInsets.all(28),
                    color: colors.surface,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tạo tài khoản',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bắt đầu theo dõi dòng tiền và ngân sách rõ ràng hơn.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 26),
                          FlowFiTextField(
                            label: 'Họ tên',
                            hint: 'Alex Morgan',
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          FlowFiTextField(
                            label: 'Email',
                            hint: 'alex@flowfi.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline_rounded,
                            validator: _required,
                          ),
                          const SizedBox(height: 14),
                          FlowFiTextField(
                            label: 'Mật khẩu',
                            hint: '••••••••',
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: _required,
                          ),
                          const SizedBox(height: 14),
                          FlowFiTextField(
                            label: 'Xác nhận mật khẩu',
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.shield_outlined,
                            validator: (value) {
                              final requiredError = _required(value);
                              if (requiredError != null) return requiredError;
                              if (value != _passwordController.text) {
                                return 'Mật khẩu xác nhận không khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          FlowFiCheckboxField(
                            label:
                                'Tôi đồng ý với Điều khoản và Chính sách riêng tư.',
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value;
                              });
                            },
                          ),
                          if (authValue.hasError) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Không thể tạo tài khoản. Vui lòng thử lại.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FlowFiButton(
                            label: 'Tạo tài khoản',
                            onPressed: isLoading || !_acceptedTerms
                                ? null
                                : _submit,
                            icon: Icons.arrow_forward_rounded,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 12),
                          FlowFiButton(
                            label: 'Quay lại đăng nhập',
                            onPressed: isLoading ? null : _returnToSignIn,
                            icon: Icons.arrow_back_rounded,
                            variant: FlowFiButtonVariant.ghost,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
        );
  }

  void _returnToSignIn() {
    Navigator.of(context).maybePop();
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Bắt buộc';
  }
  return null;
}
