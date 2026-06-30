import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';

class TransactionEntryLauncherSheet extends StatelessWidget {
  const TransactionEntryLauncherSheet({
    super.key,
    required this.onScan,
    required this.onVoice,
    required this.onManual,
  });

  final VoidCallback onScan;
  final VoidCallback onVoice;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EntryActionTile(
          icon: Icons.document_scanner_rounded,
          title: 'Quét hóa đơn',
          subtitle:
              'Chụp hoặc chọn ảnh, AI đọc dữ liệu trước khi bạn kiểm tra.',
          onTap: onScan,
        ),
        const SizedBox(height: 10),
        _EntryActionTile(
          icon: Icons.mic_rounded,
          title: 'Nói giao dịch',
          subtitle: 'Nói tự nhiên, app chuyển thành gợi ý để xác nhận.',
          onTap: onVoice,
        ),
        const SizedBox(height: 10),
        _EntryActionTile(
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
    return FlowFiCard(
      color: const Color(0xFFFFF6EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F1DA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.mic_rounded, color: Color(0xFF49672A)),
          ),
          const SizedBox(height: 12),
          Text(
            'Voice sẽ tạo gợi ý để bạn xác nhận.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Frontend đã dành chỗ cho flow này. Bước backend nên trả về draft hoặc suggestion thay vì tự xác nhận giao dịch.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF757872)),
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
        color: Color(0xFFFFF6EB),
        child: Text('Cần có ít nhất một ví và một danh mục để nhập nhanh.'),
      );
    }

    _walletId ??= _defaultWallet(wallets).id;
    _tagId ??= _defaultTag(tags).id;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Số tiền',
              hintText: 'VD: 50000',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: requiredAmount,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _tagId,
            decoration: const InputDecoration(labelText: 'Danh mục'),
            items: [
              for (final tag in tags)
                DropdownMenuItem(value: tag.id, child: Text(tag.name)),
            ],
            onChanged: _isSubmitting
                ? null
                : (value) => setState(() => _tagId = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              hintText: 'VD: Cà phê sáng',
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dùng ví ${_defaultWallet(wallets).name}, hôm nay, trạng thái đã xác nhận.',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF757872)),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : () => _submit(wallets, tags),
              child: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu giao dịch'),
            ),
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
    final type = tag.type == MoneyFlowType.unknown
        ? MoneyFlowType.expense
        : tag.type;

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

class _EntryActionTile extends StatelessWidget {
  const _EntryActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E5DC)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1DA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF49672A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757872),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowFiCard(
      child: Row(
        children: [
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
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
