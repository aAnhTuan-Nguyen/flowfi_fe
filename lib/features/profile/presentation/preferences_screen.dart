import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final _budgetController = TextEditingController();
  String _selectedCurrency = 'USD';
  bool _isLoading = true;
  bool _isSaving = false;

  static const List<String> _currencies = ['USD', 'VND', 'EUR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final data = await repo.getProfile();
      if (mounted) {
        setState(() {
          _selectedCurrency = data['currencyCode'] ?? 'USD';
          if (!_currencies.contains(_selectedCurrency)) {
             _selectedCurrency = 'USD';
          }
          final limit = data['monthlyBudgetLimit'];
          if (limit != null) {
            _budgetController.text = limit.toString();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preferences: $e')),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final budgetLimit = double.tryParse(_budgetController.text);
      await repo.updatePreferences({
        'currencyCode': _selectedCurrency,
        'monthlyBudgetLimit': budgetLimit,
      });
      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preferences: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
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
          'Currency & Preferences',
          style: AppTextStyles.headlineMd(color: context.colors.primary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display Currency',
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
                            label: 'Monthly Budget Limit (Optional)',
                            hint: 'e.g. 1000',
                            controller: _budgetController,
                            prefixIcon: Icons.account_balance_wallet_outlined,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            label: 'Save Preferences',
                            onPressed: _savePreferences,
                            icon: Icons.save_outlined,
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
