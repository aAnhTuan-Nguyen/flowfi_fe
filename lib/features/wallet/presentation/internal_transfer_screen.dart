import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/storage/secure_storage.dart';


import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';

/// Internal Transfer screen — From/To wallet selector, Amount, Note
class InternalTransferScreen extends ConsumerStatefulWidget {
  const InternalTransferScreen({super.key});

  @override
  ConsumerState<InternalTransferScreen> createState() => _InternalTransferScreenState();
}

class _InternalTransferScreenState extends ConsumerState<InternalTransferScreen> {
  final _amountController = TextEditingController(text: '0.00');
  final _noteController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _wallets = [];
  String? _fromWalletId;
  String? _toWalletId;

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
          if (wallets.isNotEmpty) {
            _fromWalletId = wallets.first['id'];
            _toWalletId = wallets.length > 1 ? wallets[1]['id'] : wallets.first['id'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wallets: $e')),
        );
      }
    }
  }

  Map<String, dynamic>? _getWallet(String? id) {
    if (id == null) return null;
    try {
      return _wallets.firstWhere((w) => w['id'] == id);
    } catch (_) {
      return null;
    }
  }

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Transfer',
          style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _wallets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
    final fromW = _getWallet(_fromWalletId);
    final toW = _getWallet(_toWalletId);

    return Column(
      children: [
        _buildWalletCard(
          title: 'FROM WALLET',
          wallet: fromW,
          selectedValue: _fromWalletId,
          onChanged: (val) {
            if (val != null) setState(() => _fromWalletId = val);
          },
          icon: Icons.account_balance_wallet_outlined,
          color: Theme.of(context).colorScheme.primary,
          bgColor: const Color(0x3322C55E),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
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
        _buildWalletCard(
          title: 'TO WALLET',
          wallet: toW,
          selectedValue: _toWalletId,
          onChanged: (val) {
            if (val != null) setState(() => _toWalletId = val);
          },
          icon: Icons.savings_outlined,
          color: Theme.of(context).colorScheme.secondary,
          bgColor: const Color(0x330051D5),
        ),
      ],
    );
  }

  Widget _buildWalletCard({
    required String title,
    required Map<String, dynamic>? wallet,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final balance = wallet != null ? '\$${(wallet['balance'] ?? 0.0).toStringAsFixed(2)}' : '\$0.00';
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ).copyWith(letterSpacing: 0.5),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    isExpanded: true,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle()).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    items: _wallets.map((w) {
                      return DropdownMenuItem<String>(
                        value: w['id'],
                        child: Text(w['name'] ?? 'Wallet', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Balance',
                style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Text(
                balance,
                style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ],
      ),
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
            style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                r'$',
                style: (Theme.of(context).textTheme.headlineLarge ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.primary),
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
                  style: (Theme.of(context).textTheme.displayMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurface),
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
            style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "What's this transfer for?",
              hintStyle: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.outline),
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outlined,
            color: Theme.of(context).colorScheme.secondary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Internal transfer is not counted as income or expense',
              style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTransfer() async {
    if (_fromWalletId == null || _toWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both wallets')),
      );
      return;
    }
    if (_fromWalletId == _toWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot transfer to the same wallet')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      final secureStorage = SecureStorageService.create();
      final userId = await secureStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final repo = ref.read(walletRepositoryProvider);
      await repo.transfer(
        userId: userId,
        fromWalletId: _fromWalletId!,
        toWalletId: _toWalletId!,
        amount: amount,
        note: _noteController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (e is DioException && e.response?.data != null) {
          errorMsg = e.response?.data.toString() ?? errorMsg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed: $errorMsg')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
