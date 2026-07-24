import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../../sync/sync_status_provider.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../../budgets/presentation/providers/budgets_provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';

class TransactionEntryLauncherSheet extends StatelessWidget {
  const TransactionEntryLauncherSheet({
    super.key,
    required this.onScan,
    required this.onManual,
  });

  final VoidCallback onScan;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlowFiActionTile(
          icon: Icons.document_scanner_rounded,
          title: 'Quét hóa đơn',
          subtitle:
              'Chụp hoặc chọn ảnh, AI đọc dữ liệu trước khi bạn kiểm tra.',
          onTap: onScan,
        ),
        const SizedBox(height: 10),

        FlowFiActionTile(
          icon: Icons.edit_note_rounded,
          title: 'Nhập nhanh',
          subtitle: 'Chỉ nhập số tiền, danh mục và ghi chú nếu cần.',
          onTap: onManual,
        ),
      ],
    );
  }
}

class VoiceTransactionPlaceholder extends StatelessWidget {
  const VoiceTransactionPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      color: FlowFiColors.warmSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FlowFiIconBadge(icon: Icons.mic_rounded, tone: FlowFiTone.info),
          const SizedBox(height: 12),
          Text(
            'Giọng nói sẽ tạo gợi ý để bạn xác nhận.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Flow này đang dành chỗ cho backend trả về bản nháp hoặc gợi ý để bạn kiểm tra.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class QuickTransactionSheet extends ConsumerStatefulWidget {
  const QuickTransactionSheet({super.key});

  @override
  ConsumerState<QuickTransactionSheet> createState() =>
      _QuickTransactionSheetState();
}

class _QuickTransactionSheetState extends ConsumerState<QuickTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _walletId;
  String? _tagId;
  MoneyFlowType _type = MoneyFlowType.expense;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final tags = ref.watch(tagsProvider);

    return wallets.when(
      loading: () => const _InlineLoading(),
      error: (_, _) => _InlineError(
        message: 'Không tải được ví.',
        onRetry: () => ref.read(walletsProvider.notifier).reload(),
      ),
      data: (walletItems) => tags.when(
        loading: () => const _InlineLoading(),
        error: (_, _) => _InlineError(
          message: 'Không tải được danh mục.',
          onRetry: () => ref.read(tagsProvider.notifier).reload(),
        ),
        data: (tagItems) => _buildForm(walletItems, tagItems),
      ),
    );
  }

  Widget _buildForm(List<Wallet> wallets, List<Tag> tags) {
    if (wallets.isEmpty || tags.isEmpty) {
      return const FlowFiCard(
        color: FlowFiColors.warmSurface,
        child: Text('Cần có ít nhất một ví và một danh mục để nhập nhanh.'),
      );
    }

    _walletId ??= _defaultWallet(wallets).id;
    
    final filteredTagItems = tags.where((tag) => tag.type == _type).toList();
    if (filteredTagItems.isNotEmpty) {
      if (_tagId == null || !filteredTagItems.any((tag) => tag.id == _tagId)) {
        _tagId = filteredTagItems.first.id;
      }
    } else {
      _tagId = null;
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _TypeToggleButton(
                  label: 'Thu',
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.white,
                  iconBackgroundColor: FlowFiColors.income,
                  backgroundColor: _type == MoneyFlowType.income ? FlowFiColors.positiveSurface : Colors.transparent,
                  borderColor: _type == MoneyFlowType.income ? FlowFiColors.income : Theme.of(context).colorScheme.outlineVariant,
                  onTap: () {
                    setState(() {
                      _type = MoneyFlowType.income;
                      _tagId = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeToggleButton(
                  label: 'Chi',
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.white,
                  iconBackgroundColor: FlowFiColors.expense,
                  backgroundColor: _type == MoneyFlowType.expense ? Theme.of(context).colorScheme.errorContainer : Colors.transparent,
                  borderColor: _type == MoneyFlowType.expense ? FlowFiColors.expense : Theme.of(context).colorScheme.outlineVariant,
                  onTap: () {
                    setState(() {
                      _type = MoneyFlowType.expense;
                      _tagId = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FlowFiTextField(
            label: 'Số tiền',
            hint: 'VD: 50000',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: requiredAmount,
          ),
          const SizedBox(height: 12),
          FlowFiSelectField<String>(
            label: 'Danh mục',
            value: _tagId,
            items: [
              for (final tag in filteredTagItems)
                FlowFiSelectItem(value: tag.id, label: tag.name),
            ],
            onChanged: _isSubmitting
                ? null
                : (value) => setState(() => _tagId = value),
          ),
          const SizedBox(height: 12),
          FlowFiTextField(
            label: 'Ghi chú',
            hint: 'VD: Cà phê sáng',
            controller: _noteController,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dùng ví ${_defaultWallet(wallets).name}, hôm nay, trạng thái đã xác nhận.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FlowFiForuiButton(
            label: 'Lưu giao dịch',
            icon: Icons.check_rounded,
            isLoading: _isSubmitting,
            onPressed: () => _submit(wallets, tags),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(List<Wallet> wallets, List<Tag> tags) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final walletId = _walletId ?? _defaultWallet(wallets).id;
    final tag = tags.firstWhere(
      (item) => item.id == _tagId,
      orElse: () => _defaultTag(tags),
    );
    final note = _noteController.text.trim();
    final title = note.isEmpty ? tag.name : note;
    final type = _type;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(transactionsProvider.notifier)
          .createTransaction(
            walletId: walletId,
            tagId: tag.id,
            title: title,
            amount: _amountController.text.trim(),
            type: type,
            date: DateTime.now(),
            status: TransactionStatus.confirmed,
            description: emptyToNull(note),
          );
      ref.invalidate(syncStatusProvider);
      ref.invalidate(walletsProvider);
      ref.invalidate(budgetsProvider);
      ref.invalidate(monthlyBudgetDetailsProvider);
      ref.invalidate(annualBudgetSummaryProvider);
      ref.invalidate(monthlyTransactionsProvider);
      ref.invalidate(annualTransactionsProvider);
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

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const FlowFiInlineLoading();
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowFiInlineError(message: message, onRetry: onRetry);
  }
}

Wallet _defaultWallet(List<Wallet> wallets) {
  return wallets.firstWhere(
    (wallet) => wallet.isDefault,
    orElse: () => wallets.first,
  );
}

Tag _defaultTag(List<Tag> tags) {
  return tags.firstWhere(
    (tag) => tag.type == MoneyFlowType.expense,
    orElse: () => tags.first,
  );
}

class _TypeToggleButton extends StatelessWidget {
  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
