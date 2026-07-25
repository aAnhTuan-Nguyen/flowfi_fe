import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../budgets/presentation/providers/budgets_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/presentation/widgets/transaction_form_sheet.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../domain/entities/ai_image_file.dart';
import '../../domain/entities/image_transaction_import.dart';
import '../providers/image_transaction_import_provider.dart';

typedef PickAiImageFile = Future<AiImageFile?> Function(ImageSource source);

class ImageTransactionImportSheet extends ConsumerStatefulWidget {
  const ImageTransactionImportSheet({
    super.key,
    this.pickImageFile = pickAiImageFile,
  });

  final PickAiImageFile pickImageFile;

  @override
  ConsumerState<ImageTransactionImportSheet> createState() =>
      _ImageTransactionImportSheetState();
}

class _ImageTransactionImportSheetState
    extends ConsumerState<ImageTransactionImportSheet> {
  String? _walletId;
  AiImageFile? _image;
  ImageTransactionImport? _result;
  String? _errorMessage;
  String? _successMessage;
  bool _isSubmitting = false;
  final Set<String> _busyDraftIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);

    return wallets.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải ví'),
      error: (_, _) => FlowFiInlineError(
        message: 'Không tải được ví.',
        onRetry: () => ref.read(walletsProvider.notifier).reload(),
      ),
      data: _buildContent,
    );
  }

  Widget _buildContent(List<Wallet> wallets) {
    if (wallets.isEmpty) {
      return const FlowFiCard(
        color: FlowFiColors.warmSurface,
        child: Text('Tạo ít nhất một ví trước khi quét hóa đơn.'),
      );
    }

    _walletId ??= wallets.first.id;
    final result = _result;
    final selectedWallet = wallets.firstWhere(
      (wallet) => wallet.id == _walletId,
      orElse: () => wallets.first,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowFiSelectField<String>(
            label: 'Ví',
            value: _walletId,
            items: [
              for (final wallet in wallets)
                FlowFiSelectItem(
                  value: wallet.id,
                  label: wallet.name,
                  icon: Icons.account_balance_wallet_rounded,
                ),
            ],
            onChanged: _isSubmitting
                ? null
                : (value) => setState(() => _walletId = value),
          ),
          const SizedBox(height: 12),
          const _ScanNotice(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FlowFiButton(
                  label: 'Chụp ảnh',
                  onPressed: _isSubmitting
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: Icons.photo_camera_rounded,
                  variant: FlowFiButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FlowFiButton(
                  label: 'Chọn ảnh',
                  onPressed: _isSubmitting
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: Icons.image_rounded,
                  variant: FlowFiButtonVariant.outline,
                ),
              ),
            ],
          ),
          if (_image != null) ...[
            const SizedBox(height: 12),
            _SelectedImageCard(image: _image!),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 12),
            _SuccessNotice(message: _successMessage!),
          ],
          const SizedBox(height: 14),
          _ScanSubmitButton(
            label: _isSubmitting ? 'Đang quét...' : 'Quét ảnh',
            onPressed: _canSubmit ? _submit : null,
            isLoading: _isSubmitting,
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            _ImportResultCard(
              result: result,
              wallet: selectedWallet,
              busyDraftIds: _busyDraftIds,
              onEdit: _editDraft,
              onConfirm: _confirmDraft,
              onDelete: _deleteDraft,
            ),
          ],
        ],
      ),
    );
  }

  bool get _canSubmit => !_isSubmitting && _walletId != null && _image != null;

  Future<void> _pickImage(ImageSource source) async {
    final image = await widget.pickImageFile(source);
    if (!mounted || image == null) {
      return;
    }
    try {
      validateAiImageFile(image);
      setState(() {
        _image = image;
        _result = null;
        _errorMessage = null;
        _successMessage = null;
      });
    } on AiImageValidationException catch (error) {
      setState(() {
        _image = null;
        _result = null;
        _errorMessage = error.message;
        _successMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    final walletId = _walletId;
    final image = _image;
    if (walletId == null || image == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final result = await ref
          .read(imageTransactionImportProvider.notifier)
          .createTransactionsFromImage(walletId: walletId, image: image);
      ref.invalidate(transactionsProvider);
      ref.invalidate(tagsProvider);
      ref.invalidate(notificationsProvider);
      ref.invalidate(walletsProvider);
      ref.invalidate(budgetsProvider);
      ref.invalidate(monthlyTransactionsProvider);
      ref.invalidate(monthlyTransactionSummaryProvider);
      ref.invalidate(annualTransactionsProvider);
      ref.invalidate(monthlyBudgetDetailsProvider);
      ref.invalidate(annualBudgetSummaryProvider);
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _isSubmitting = false;
      });
    } on AiImageValidationException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
          _isSubmitting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không quét được ảnh này. Vui lòng thử lại.';
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _editDraft(Transaction transaction) async {
    await showFlowFiFormSheet<void>(
      context: context,
      title: 'Sửa giao dịch nháp',
      child: TransactionFormSheet(transaction: transaction),
    );
    if (!mounted) {
      return;
    }
    ref.invalidate(transactionsProvider);
    ref.invalidate(tagsProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(walletsProvider);
    ref.invalidate(budgetsProvider);
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(monthlyTransactionSummaryProvider);
    ref.invalidate(annualTransactionsProvider);
    ref.invalidate(monthlyBudgetDetailsProvider);
    ref.invalidate(annualBudgetSummaryProvider);
  }

  Future<void> _confirmDraft(Transaction transaction) async {
    if (!_startDraftAction(transaction.id)) {
      return;
    }
    try {
      await ref
          .read(transactionsProvider.notifier)
          .confirmTransaction(transaction.id);
      ref.invalidate(walletsProvider);
      ref.invalidate(budgetsProvider);
      ref.invalidate(goalsProvider);
      ref.invalidate(notificationsProvider);
      ref.invalidate(monthlyTransactionsProvider);
      ref.invalidate(monthlyTransactionSummaryProvider);
      ref.invalidate(annualTransactionsProvider);
      ref.invalidate(monthlyBudgetDetailsProvider);
      ref.invalidate(annualBudgetSummaryProvider);
      if (mounted) {
        setState(() {
          _result = _withoutTransaction(_result, transaction.id);
          _successMessage = 'Đã xác nhận giao dịch thành công.';
        });
      }
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
      }
    } finally {
      _finishDraftAction(transaction.id);
    }
  }

  Future<void> _deleteDraft(Transaction transaction) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Xóa giao dịch nháp?',
      message: 'Giao dịch nháp OCR này sẽ bị xóa khỏi FlowFi.',
      actionLabel: 'Xóa giao dịch',
    );
    if (!confirmed || !_startDraftAction(transaction.id)) {
      return;
    }
    try {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(transaction.id);
      await ref.read(notificationsProvider.notifier).reload();
      if (mounted) {
        setState(() {
          _result = _withoutTransaction(_result, transaction.id);
        });
      }
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
      }
    } finally {
      _finishDraftAction(transaction.id);
    }
  }

  bool _startDraftAction(String id) {
    if (_busyDraftIds.contains(id)) {
      return false;
    }
    setState(() {
      _busyDraftIds.add(id);
      _errorMessage = null;
      _successMessage = null;
    });
    return true;
  }

  void _finishDraftAction(String id) {
    if (!mounted) {
      return;
    }
    setState(() {
      _busyDraftIds.remove(id);
    });
  }
}

class _ScanNotice extends StatelessWidget {
  const _ScanNotice();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI đã tạo nháp từ hóa đơn.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kiểm tra trước khi xác nhận để số dư ví không bị đổi nhầm.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessNotice extends StatelessWidget {
  const _SuccessNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedImageCard extends StatelessWidget {
  const _SelectedImageCard({required this.image});

  final AiImageFile image;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              Uint8List.fromList(image.bytes),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 52,
                  height: 52,
                  color: FlowFiColors.imagePlaceholder,
                  child: const Icon(Icons.receipt_long_rounded),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              image.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary),
            ),
            child: Icon(Icons.check_rounded, color: colors.primary, size: 17),
          ),
        ],
      ),
    );
  }
}

class _ScanSubmitButton extends StatelessWidget {
  const _ScanSubmitButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: enabled ? const Color(0xFF111111) : colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Center(
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.document_scanner_outlined,
                        size: 18,
                        color: enabled ? Colors.white : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: enabled
                                  ? Colors.white
                                  : colors.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ImportResultCard extends StatelessWidget {
  const _ImportResultCard({
    required this.result,
    required this.wallet,
    required this.busyDraftIds,
    required this.onEdit,
    required this.onConfirm,
    required this.onDelete,
  });

  final ImageTransactionImport result;
  final Wallet wallet;
  final Set<String> busyDraftIds;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<Transaction> onConfirm;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    final drafts = result.createdTransactions;
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniStatusIcon(
                icon: Icons.check_rounded,
                color: colors.primary,
                backgroundColor: colors.surfaceContainerLowest,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drafts.isEmpty
                          ? 'Đã xử lý tất cả giao dịch nháp.'
                          : 'AI đã tạo nháp từ hóa đơn',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      drafts.isEmpty
                          ? 'Không còn nháp nào cần xác nhận.'
                          : 'Hãy kiểm tra chi tiết trước khi xác nhận.',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (result.imageType != null) ...[
            const SizedBox(height: 4),
            Text(
              'Loại ảnh: ${result.imageType}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (drafts.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final item in drafts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OcrDraftTile(
                  transaction: item.transaction,
                  walletName: wallet.name,
                  confidence: result.confidence,
                  receiptDetails: result.receiptDetails,
                  isBusy: busyDraftIds.contains(item.transaction.id),
                  onEdit: onEdit,
                  onConfirm: onConfirm,
                  onDelete: onDelete,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OcrDraftTile extends StatelessWidget {
  const _OcrDraftTile({
    required this.transaction,
    required this.walletName,
    required this.confidence,
    required this.receiptDetails,
    required this.isBusy,
    required this.onEdit,
    required this.onConfirm,
    required this.onDelete,
  });

  final Transaction transaction;
  final String walletName;
  final String? confidence;
  final List<ReceiptDetail> receiptDetails;
  final bool isBusy;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<Transaction> onConfirm;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniStatusIcon(
                icon: Icons.shopping_cart_outlined,
                color: colors.primary,
                backgroundColor: colors.surfaceContainerLowest,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.merchantName ?? 'AI OCR từ hóa đơn',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatSignedAmount(transaction),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: flowFiToneStyle(
                    context,
                    FlowFiTone.negative,
                  ).foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ReceiptDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày giao dịch',
            value: _formatDate(transaction.date),
          ),
          _ReceiptDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Giờ giao dịch',
            value: _formatTime(transaction.date),
          ),
          _ReceiptDetailRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Ví',
            value: walletName,
          ),
          _ReceiptDetailRow(
            icon: Icons.sell_outlined,
            label: 'Danh mục',
            value: _categoryLabel(transaction),
            trailing: _SoftPill(
              label: _categoryLabel(transaction),
              tone: FlowFiTone.positive,
            ),
          ),
          _ReceiptDetailRow(
            icon: Icons.swap_vert_rounded,
            label: 'Loại giao dịch',
            value: _typeLabel(transaction.type),
            trailing: _SoftPill(
              label: _typeLabel(transaction.type),
              tone: transaction.type == MoneyFlowType.income
                  ? FlowFiTone.positive
                  : FlowFiTone.warning,
            ),
          ),
          _ReceiptDetailRow(
            icon: Icons.store_outlined,
            label: 'Nhà cung cấp',
            value: transaction.merchantName ?? transaction.title,
          ),
          _ReceiptDetailRow(
            icon: Icons.receipt_long_outlined,
            label: 'Nguồn dữ liệu',
            value: 'AI OCR từ hóa đơn',
            showDivider: receiptDetails.isNotEmpty,
          ),
          if (receiptDetails.isNotEmpty) ...[
            for (final detail in receiptDetails.take(3))
              _ReceiptDetailRow(
                icon: Icons.shopping_bag_outlined,
                label: detail.name,
                value:
                    '${_formatQuantity(detail.quantity)} x ${_formatPlainAmount(detail.price)}',
              ),
          ],
          const SizedBox(height: 10),
          _OcrActionBar(
            isBusy: isBusy,
            onEdit: () => onEdit(transaction),
            onConfirm: () => onConfirm(transaction),
            onDelete: () => onDelete(transaction),
          ),
        ],
      ),
    );
  }
}

class _MiniStatusIcon extends StatelessWidget {
  const _MiniStatusIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 24,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Icon(icon, color: color, size: size * 0.56),
    );
  }
}

class _ReceiptDetailRow extends StatelessWidget {
  const _ReceiptDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outlineVariant))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (trailing != null)
            trailing!
          else
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.label, required this.tone});

  final String label;
  final FlowFiTone tone;

  @override
  Widget build(BuildContext context) {
    final toneStyle = flowFiToneStyle(context, tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: toneStyle.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: toneStyle.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OcrActionBar extends StatelessWidget {
  const _OcrActionBar({
    required this.isBusy,
    required this.onEdit,
    required this.onConfirm,
    required this.onDelete,
  });

  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _SheetActionButton(
            label: 'Sửa thông tin',
            icon: Icons.edit_outlined,
            onPressed: isBusy ? null : onEdit,
            variant: _SheetActionVariant.outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: _SheetActionButton(
            label: 'Xác nhận giao dịch',
            icon: Icons.check_circle_outline_rounded,
            onPressed: isBusy ? null : onConfirm,
            isLoading: isBusy,
            variant: _SheetActionVariant.dark,
          ),
        ),
        const SizedBox(width: 8),
        _SheetIconActionButton(onPressed: isBusy ? null : onDelete),
      ],
    );
  }
}

enum _SheetActionVariant { outline, dark }

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final _SheetActionVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;
    final dark = variant == _SheetActionVariant.dark;
    final backgroundColor = dark
        ? enabled
              ? const Color(0xFF111111)
              : colors.surfaceContainerHigh
        : colors.surfaceContainerLowest;
    final foregroundColor = dark
        ? Colors.white
        : enabled
        ? colors.onSurface
        : colors.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: dark ? null : Border.all(color: colors.outlineVariant),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 17, color: foregroundColor),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: foregroundColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SheetIconActionButton extends StatelessWidget {
  const _SheetIconActionButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? colors.error.withValues(alpha: 0.45)
                  : colors.outlineVariant,
            ),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: enabled ? colors.error : colors.onSurfaceVariant,
            size: 21,
          ),
        ),
      ),
    );
  }
}

ImageTransactionImport? _withoutTransaction(
  ImageTransactionImport? result,
  String transactionId,
) {
  if (result == null) {
    return null;
  }
  return ImageTransactionImport(
    aiRequestId: result.aiRequestId,
    aiResultId: result.aiResultId,
    imageUrl: result.imageUrl,
    imageType: result.imageType,
    confidence: result.confidence,
    warnings: result.warnings,
    receiptDetails: result.receiptDetails,
    createdTransactions: result.createdTransactions
        .where((item) => item.transaction.id != transactionId)
        .toList(growable: false),
  );
}

String _formatSignedAmount(Transaction transaction) {
  final amount = double.tryParse(transaction.amount) ?? 0;
  final sign = transaction.type == MoneyFlowType.expense ? '-' : '+';
  return '$sign${_formatPlainAmount(amount.abs())} đ';
}

String _formatPlainAmount(num value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    if (i > 0 && (rounded.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(rounded[i]);
  }
  return buffer.toString();
}

String _formatQuantity(num value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Chưa xác định';
  }
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatTime(DateTime? date) {
  if (date == null) {
    return 'Chưa xác định';
  }
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _categoryLabel(Transaction transaction) {
  final title = transaction.title.toLowerCase();
  final merchant = transaction.merchantName?.toLowerCase() ?? '';
  if (title.contains('salary') || title.contains('lương')) {
    return 'Thu nhập';
  }
  if (merchant.contains('bách hóa') ||
      merchant.contains('winmart') ||
      title.contains('receipt')) {
    return 'Mua sắm';
  }
  return transaction.tagId ?? 'Chưa phân loại';
}

String _typeLabel(MoneyFlowType type) {
  return switch (type) {
    MoneyFlowType.income => 'Thu nhập',
    MoneyFlowType.expense => 'Chi tiêu',
    MoneyFlowType.unknown => 'Chưa rõ',
  };
}

Future<AiImageFile?> pickAiImageFile(ImageSource source) async {
  final picked = await ImagePicker().pickImage(source: source);
  if (picked == null) {
    return null;
  }
  final bytes = await picked.readAsBytes();
  return AiImageFile(
    name: picked.name,
    bytes: bytes,
    mimeType: _mimeTypeFor(picked),
  );
}

String _mimeTypeFor(XFile file) {
  final mimeType = file.mimeType?.trim().toLowerCase();
  if (mimeType != null && mimeType.isNotEmpty) {
    return mimeType;
  }
  final name = file.name.toLowerCase();
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
