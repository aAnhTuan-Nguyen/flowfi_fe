import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';

/// Internal Transfer screen — From/To wallet selector, Amount, Note
class InternalTransferScreen extends StatefulWidget {
  const InternalTransferScreen({super.key});

  @override
  State<InternalTransferScreen> createState() => _InternalTransferScreenState();
}

class _InternalTransferScreenState extends State<InternalTransferScreen> {
  final _amountController = TextEditingController(text: '0.00');
  final _noteController = TextEditingController();
  bool _loading = false;

  ({String name, String subtitle, String balance, IconData icon, Color color, Color bgColor}) get _fromWallet => (
    name: 'Main Account',
    subtitle: 'FROM WALLET',
    balance: r'$12,450.00',
    icon: Icons.account_balance_wallet_outlined,
    color: context.colors.primary,
    bgColor: const Color(0x3322C55E),
  );

  ({String name, String subtitle, String balance, IconData icon, Color color, Color bgColor}) get _toWallet => (
    name: 'Emergency Fund',
    subtitle: 'TO WALLET',
    balance: r'$3,200.00',
    icon: Icons.savings_outlined,
    color: context.colors.secondary,
    bgColor: const Color(0x330051D5),
  );

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setQuickAmount(String amount) {
    _amountController.text = amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Transfer',
          style: AppTextStyles.headlineMd(color: context.colors.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildWalletSelector(),
              const SizedBox(height: 24),
              _buildAmountSection(),
              const SizedBox(height: 20),
              _buildNoteSection(),
              const SizedBox(height: 16),
              _buildInfoBanner(),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Transfer',
                onPressed: _onTransfer,
                loading: _loading,
                icon: Icons.swap_horiz,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSelector() {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _fromWallet.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _fromWallet.icon,
                  color: _fromWallet.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fromWallet.subtitle,
                      style: AppTextStyles.labelSm(
                        color: context.colors.onSurfaceVariant,
                      ).copyWith(letterSpacing: 0.5),
                    ),
                    Text(
                      _fromWallet.name,
                      style: AppTextStyles.headlineLgMobile(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Balance',
                    style: AppTextStyles.labelSm(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _fromWallet.balance,
                    style: AppTextStyles.numericBold(color: context.colors.onSurface),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _toWallet.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _toWallet.icon,
                  color: _toWallet.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toWallet.subtitle,
                      style: AppTextStyles.labelSm(
                        color: context.colors.onSurfaceVariant,
                      ).copyWith(letterSpacing: 0.5),
                    ),
                    Text(
                      _toWallet.name,
                      style: AppTextStyles.headlineLgMobile(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Balance',
                    style: AppTextStyles.labelSm(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _toWallet.balance,
                    style: AppTextStyles.numericBold(
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: AppTextStyles.labelMd(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                r'$',
                style: AppTextStyles.headlineLg(color: context.colors.primary),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onTap: () {
                    if (_amountController.text == '0' || _amountController.text == '0.0' || _amountController.text == '0.00') {
                      _amountController.clear();
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  style: AppTextStyles.displayLg(color: context.colors.onSurface),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuickAmountChip(
                label: r'$100',
                onTap: () => _setQuickAmount('100.00'),
              ),
              const SizedBox(width: 8),
              _QuickAmountChip(
                label: r'$500',
                onTap: () => _setQuickAmount('500.00'),
              ),
              const SizedBox(width: 8),
              _QuickAmountChip(
                label: r'$1,000',
                onTap: () => _setQuickAmount('1000.00'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note (Optional)',
            style: AppTextStyles.labelMd(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: AppTextStyles.bodyMd(color: context.colors.onSurface),
            decoration: InputDecoration(
              hintText: "What's this transfer for?",
              hintStyle: AppTextStyles.bodyMd(color: context.colors.outline),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outlined,
            color: context.colors.secondary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Internal transfer is not counted as income or expense',
              style: AppTextStyles.labelMd(color: context.colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  void _onTransfer() {
    setState(() => _loading = true);
    // Backend integration: call WalletRepository.transfer()
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.of(context).pop();
      }
    });
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd(color: context.colors.onSurface),
        ),
      ),
    );
  }
}
