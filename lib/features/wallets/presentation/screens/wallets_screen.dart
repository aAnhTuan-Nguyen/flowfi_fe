import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/wallet.dart';
import '../providers/wallets_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Wallets',
      subtitle: 'Track balances across cash, bank, and e-wallets.',
      onRefresh: () => ref.read(walletsProvider.notifier).reload(),
      actions: [
        FilledButton.icon(
          onPressed: () => _showWalletForm(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add wallet'),
        ),
      ],
      child: wallets.when(
        loading: () => const _LoadingState(),
        error: (_, _) => FlowFiErrorState(
          onRetry: () => ref.read(walletsProvider.notifier).reload(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const FlowFiEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No wallets yet',
              message: 'Add a wallet to start testing the API.',
            );
          }
          return separatedSliverList(
            itemCount: items.length,
            itemBuilder: (context, index) => _WalletCard(wallet: items[index]),
          );
        },
      ),
    );
  }
}

class _WalletCard extends ConsumerWidget {
  const _WalletCard({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: wallet.isDefault
                  ? const Color(0xFF49672A)
                  : colors.secondaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _walletIcon(wallet.type),
              color: wallet.isDefault ? Colors.white : const Color(0xFF49672A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (wallet.isDefault)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Color(0xFF49672A),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _walletTypeLabel(wallet.type),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF757872),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            wallet.balance,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.end,
          ),
          PopupMenuButton<_WalletAction>(
            tooltip: 'Wallet actions',
            onSelected: (action) async {
              switch (action) {
                case _WalletAction.edit:
                  await _showWalletForm(context, ref, wallet: wallet);
                case _WalletAction.setDefault:
                  try {
                    await ref
                        .read(walletsProvider.notifier)
                        .setDefaultWallet(wallet.id);
                  } catch (_) {
                    if (context.mounted) {
                      showGenericMutationError(context);
                    }
                  }
                case _WalletAction.delete:
                  final confirmed = await confirmDestructiveAction(
                    context,
                    title: 'Delete wallet?',
                    message: 'This removes the wallet from FlowFi.',
                  );
                  if (confirmed && context.mounted) {
                    try {
                      await ref
                          .read(walletsProvider.notifier)
                          .deleteWallet(wallet.id);
                    } catch (_) {
                      if (context.mounted) {
                        showGenericMutationError(context);
                      }
                    }
                  }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _WalletAction.edit,
                child: Text('Edit'),
              ),
              if (!wallet.isDefault)
                const PopupMenuItem(
                  value: _WalletAction.setDefault,
                  child: Text('Set default'),
                ),
              const PopupMenuItem(
                value: _WalletAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _WalletAction { edit, setDefault, delete }

Future<void> _showWalletForm(
  BuildContext context,
  WidgetRef ref, {
  Wallet? wallet,
}) {
  return showFlowFiFormSheet<void>(
    context: context,
    title: wallet == null ? 'Add wallet' : 'Edit wallet',
    child: _WalletForm(wallet: wallet),
  );
}

class _WalletForm extends ConsumerStatefulWidget {
  const _WalletForm({this.wallet});

  final Wallet? wallet;

  @override
  ConsumerState<_WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends ConsumerState<_WalletForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late WalletType _type;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet?.balance ?? '',
    );
    _type = widget.wallet?.type == WalletType.unknown
        ? WalletType.cash
        : widget.wallet?.type ?? WalletType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<WalletType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: WalletType.cash, child: Text('Cash')),
              DropdownMenuItem(value: WalletType.bank, child: Text('Bank')),
              DropdownMenuItem(
                value: WalletType.eWallet,
                child: Text('E-Wallet'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _balanceController,
            decoration: const InputDecoration(labelText: 'Balance'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: optionalAmount,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.wallet == null ? 'Create wallet' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final balance = emptyToNull(_balanceController.text.trim());
      final notifier = ref.read(walletsProvider.notifier);
      if (widget.wallet == null) {
        await notifier.createWallet(
          name: _nameController.text.trim(),
          type: _type,
          balance: balance,
        );
      } else {
        await notifier.updateWallet(
          widget.wallet!.id,
          name: _nameController.text.trim(),
          type: _type,
          balance: balance,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

IconData _walletIcon(WalletType type) {
  return switch (type) {
    WalletType.cash => Icons.payments_rounded,
    WalletType.bank => Icons.account_balance_rounded,
    WalletType.eWallet => Icons.phone_iphone_rounded,
    WalletType.unknown => Icons.account_balance_wallet_rounded,
  };
}

String _walletTypeLabel(WalletType type) {
  return switch (type) {
    WalletType.cash => 'Cash',
    WalletType.bank => 'Bank',
    WalletType.eWallet => 'E-Wallet',
    WalletType.unknown => 'Wallet',
  };
}
