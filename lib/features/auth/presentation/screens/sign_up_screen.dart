import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                          color: const Color(0xFFE7F1DA),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: Color(0xFF49672A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'FlowFi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Back to login',
                        onPressed: isLoading ? null : _returnToSignIn,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create account',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Experience next-gen financial clarity.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF74786E),
                                ),
                          ),
                          const SizedBox(height: 26),
                          _Label('Full Name'),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: _decor(
                              'Alex Morgan',
                              Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _Label('Email Address'),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _decor(
                              'alex@flowfi.com',
                              Icons.mail_outline_rounded,
                            ),
                            validator: _required,
                          ),
                          const SizedBox(height: 14),
                          _Label('Password'),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: _decor(
                              '........',
                              Icons.lock_outline_rounded,
                            ),
                            validator: _required,
                          ),
                          const SizedBox(height: 14),
                          _Label('Confirm Password'),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: _decor(
                              '........',
                              Icons.shield_outlined,
                            ),
                            validator: (value) {
                              final requiredError = _required(value);
                              if (requiredError != null) return requiredError;
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _acceptedTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'I agree to the Terms and Privacy Policy.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (authValue.hasError) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Could not create your account. Please try again.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: isLoading || !_acceptedTerms
                                ? null
                                : _submit,
                            label: const Text('Create Account'),
                            icon: isLoading
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_rounded),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: isLoading ? null : _returnToSignIn,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back to Login'),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'LUMINOUS CORE INTELLIGENCE',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFFB9BDAF),
                                  letterSpacing: 1.2,
                                ),
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 10,
          color: const Color(0xFF74786E),
        ),
      ),
    );
  }
}

InputDecoration _decor(String hintText, IconData icon) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(icon, size: 18),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}
