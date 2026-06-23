import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';

class CreateWalletScreen extends ConsumerStatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  ConsumerState<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends ConsumerState<CreateWalletScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.0');
  String _selectedCurrency = 'USD';
  bool _isLoading = false;

  static const List<String> _currencies = ['USD', 'VND', 'EUR', 'GBP'];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _createWallet() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a wallet name')),
      );
      return;
    }

    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.createWallet({
        'name': _nameController.text.trim(),
        'currency': _selectedCurrency,
        'balance': balance,
      });

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create wallet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Wallet',
          style: AppTextStyles.headlineMd(color: context.colors.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Wallet Name',
                      hint: 'e.g. Cash, Checking Account',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Currency',
                      style: AppTextStyles.labelMd(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          style: AppTextStyles.bodyMd(
                            color: context.colors.onSurface,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: context.colors.outline,
                          ),
                          items: _currencies
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCurrency = v ?? 'USD'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Initial Balance',
                      hint: '0.00',
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onTap: () {
                        if (_balanceController.text == '0' || _balanceController.text == '0.0' || _balanceController.text == '0.00') {
                          _balanceController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      label: 'Create Wallet',
                      onPressed: _createWallet,
                      icon: Icons.add_card,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
