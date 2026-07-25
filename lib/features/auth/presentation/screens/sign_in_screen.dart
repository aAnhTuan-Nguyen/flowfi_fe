import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../providers/auth_controller.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.initialMessage});

  final String? initialMessage;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _signUpSuccessMessage;

  @override
  void initState() {
    super.initState();
    _emailController.text = ref.read(signInEmailProvider);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authValue = ref.watch(authControllerProvider);
    final isLoading = authValue.isLoading;
    final errorText = authValue.hasError
        ? 'Không thể đăng nhập. Kiểm tra email và mật khẩu.'
        : widget.initialMessage;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                children: [
                  Text(
                    'FlowFi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _AuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Chào mừng trở lại',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Quản lý tài chính rõ ràng hơn với FlowFi.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 22),
                          FlowFiTextField(
                            label: 'Email',
                            hint: 'alex@example.com',
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
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: _required,
                          ),
                          if (errorText != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              errorText,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          if (_signUpSuccessMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _signUpSuccessMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: colors.primary),
                            ),
                          ],
                          const SizedBox(height: 18),
                          FlowFiButton(
                            label: 'Đăng nhập',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'HOẶC',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: const Color(0xFFB5AA76),
                                        letterSpacing: 0,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FlowFiButton(
                            label: 'Tạo tài khoản',
                            variant: FlowFiButtonVariant.outline,
                            onPressed: _openSignUp,
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
    final email = _emailController.text.trim();
    ref.read(signInEmailProvider.notifier).remember(email);
    await ref
        .read(authControllerProvider.notifier)
        .signIn(email: email, password: _passwordController.text);
  }

  Future<void> _openSignUp() async {
    final result = await Navigator.of(context).push<SignUpSuccess>(
      MaterialPageRoute<SignUpSuccess>(builder: (_) => const SignUpScreen()),
    );
    if (!mounted || result == null) return;
    ref.read(signInEmailProvider.notifier).remember(result.email);
    setState(() {
      _emailController.text = result.email;
      _passwordController.clear();
      _signUpSuccessMessage =
          'Đăng ký thành công. Vui lòng đăng nhập để tiếp tục.';
    });
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      color: colors.surface,
      child: child,
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Bắt buộc';
  }
  return null;
}
