import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/wallet.dart';
import '../providers/wallets_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Ví',
      subtitle: 'Theo dõi tiền mặt, ngân hàng và ví điện tử.',
      onRefresh: () => ref.read(walletsProvider.notifier).reload(),
      actions: [
        FlowFiButton(
          label: 'Thêm ví',
          onPressed: () => _showWalletForm(context, ref),
          icon: Icons.add_rounded,
          fullWidth: false,
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
              title: 'Chưa có ví',
              message: 'Thêm ví đầu tiên để FlowFi tính số dư chính xác hơn.',
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
    final tone = wallet.isDefault ? FlowFiTone.positive : FlowFiTone.info;

    return FlowFiListItemCard(
      icon: _walletIcon(wallet.type),
      tone: tone,
      title: wallet.name,
      subtitle: _walletTypeLabel(wallet.type),
      status: wallet.isDefault
          ? const FlowFiStatusBadge(
              label: 'Mặc định',
              icon: Icons.check_rounded,
              tone: FlowFiTone.positive,
            )
          : null,
      trailing: FlowFiAmountText(
        amount: wallet.balance,
        currencyCode: '₫',
        align: TextAlign.end,
      ),
      action: FlowFiActionMenu(
        tooltip: 'Tùy chọn ví',
        actions: [
          FlowFiMenuAction(
            label: 'Sửa',
            icon: Icons.edit_rounded,
            onSelected: () => _showWalletForm(context, ref, wallet: wallet),
          ),
          if (!wallet.isDefault)
            FlowFiMenuAction(
              label: 'Đặt mặc định',
              icon: Icons.check_circle_outline_rounded,
              onSelected: () => _setDefault(context, ref),
            ),
          FlowFiMenuAction(
            label: 'Xóa',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onSelected: () => _delete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _setDefault(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(walletsProvider.notifier).setDefaultWallet(wallet.id);
    } catch (_) {
      if (context.mounted) {
        showGenericMutationError(context);
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Xóa ví?',
      message: 'Ví này sẽ bị xóa khỏi FlowFi.',
    );
    if (confirmed && context.mounted) {
      try {
        await ref.read(walletsProvider.notifier).deleteWallet(wallet.id);
      } catch (_) {
        if (context.mounted) {
          showGenericMutationError(context);
        }
      }
    }
  }
}

Future<void> _showWalletForm(
  BuildContext context,
  WidgetRef ref, {
  Wallet? wallet,
}) {
  return showFlowFiFormSheet<void>(
    context: context,
    title: wallet == null ? 'Thêm ví mới' : 'Sửa ví',
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
          FlowFiTextField(
            label: 'Tên ví',
            controller: _nameController,
            textInputAction: TextInputAction.next,
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          FlowFiSelectField<WalletType>(
            label: 'Loại ví',
            value: _type,
            items: const [
              FlowFiSelectItem(
                value: WalletType.cash,
                label: 'Tiền mặt',
                icon: Icons.payments_rounded,
              ),
              FlowFiSelectItem(
                value: WalletType.bank,
                label: 'Ngân hàng',
                icon: Icons.account_balance_rounded,
              ),
              FlowFiSelectItem(
                value: WalletType.eWallet,
                label: 'Ví điện tử',
                icon: Icons.phone_iphone_rounded,
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
          const SizedBox(height: 12),
          FlowFiTextField(
            label: 'Số dư ban đầu',
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: optionalAmount,
          ),
          const SizedBox(height: 18),
          FlowFiForuiButton(
            label: widget.wallet == null ? 'Tạo ví' : 'Lưu thay đổi',
            icon: Icons.check_rounded,
            isLoading: _isSubmitting,
            onPressed: _submit,
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
      child: Center(child: FlowFiInlineLoading()),
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
    WalletType.cash => 'Tiền mặt',
    WalletType.bank => 'Ngân hàng',
    WalletType.eWallet => 'Ví điện tử',
    WalletType.unknown => 'Ví',
  };
}
