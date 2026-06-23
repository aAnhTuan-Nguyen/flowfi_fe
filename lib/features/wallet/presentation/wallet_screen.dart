import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_router.dart';
import '../../../core/widgets/flowfi_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/wallet_card.dart';
import '../../../core/widgets/charts/portfolio_line_chart.dart';

/// Wallet Management screen — total assets, wallet list, portfolio chart
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    try {
      final repo = ref.read(walletRepositoryProvider);
      final wallets = await repo.getWallets();
      if (mounted) {
        setState(() {
          _wallets = wallets;
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
        backgroundColor: context.colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalAssets = _wallets.fold<double>(
      0.0,
      (sum, w) => sum + ((w['balance'] as num?)?.toDouble() ?? 0.0),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: const FlowFiAppBar(title: 'FlowFi'),
      body: RefreshIndicator(
        onRefresh: _loadWallets,
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            bottom: 100,
          ),
          children: [
            _buildTotalAssetsCard(context, totalAssets),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Your Wallets',
              actionLabel: '${_wallets.length} Active',
            ),
            const SizedBox(height: 12),
            if (_wallets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No wallets found.')),
              )
            else
              ..._wallets.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WalletCard(
                    name: w['name'] ?? 'Wallet',
                    subtitle: w['currencyCode'] ?? 'USD',
                    balance: '\$${(w['balance'] ?? 0.0).toStringAsFixed(2)}',
                    iconData: Icons.account_balance_wallet,
                    accentColor: context.colors.primary,
                    iconBgColor: context.colors.primaryContainer.withValues(alpha: 0.2),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _buildPortfolioChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAssetsCard(BuildContext context, double totalAssets) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Assets',
            style: AppTextStyles.labelMd(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${totalAssets.toStringAsFixed(2)}',
            style: AppTextStyles.displayLg(color: context.colors.primary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: context.colors.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '+0.0% from last month',
                style: AppTextStyles.labelSm(color: context.colors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.createWallet),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Create Wallet'),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.transfer),
            icon: const Icon(Icons.swap_horiz, size: 20),
            label: const Text('Transfer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: context.colors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioChart() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Growth',
            style: AppTextStyles.labelMd(color: context.colors.onSurface)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const PortfolioLineChart(),
        ],
      ),
    );
  }
}
