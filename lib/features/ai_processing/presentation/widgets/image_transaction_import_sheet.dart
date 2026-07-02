import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
          const FlowFiCard(
            color: FlowFiColors.warmSurface,
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI sẽ tạo nháp từ hóa đơn. Kiểm tra lại trước khi xác nhận để số dư ví không bị đổi nhầm.',
                  ),
                ),
              ],
            ),
          ),
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
            FlowFiCard(
              color: FlowFiColors.warmSurface,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      Uint8List.fromList(_image!.bytes),
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
                      _image!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
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
          const SizedBox(height: 14),
          FlowFiButton(
            label: _isSubmitting ? 'Đang quét...' : 'Quét ảnh',
            onPressed: _canSubmit ? _submit : null,
            icon: Icons.document_scanner_rounded,
            isLoading: _isSubmitting,
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            _ImportResultCard(
              result: result,
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
      });
    } on AiImageValidationException catch (error) {
      setState(() {
        _image = null;
        _result = null;
        _errorMessage = error.message;
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
    });
    try {
      final result = await ref
          .read(imageTransactionImportProvider.notifier)
          .createTransactionsFromImage(walletId: walletId, image: image);
      await Future.wait([
        ref.read(transactionsProvider.notifier).reload(),
        ref.read(tagsProvider.notifier).reload(),
        ref.read(notificationsProvider.notifier).reload(),
      ]);
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
    await Future.wait([
      ref.read(transactionsProvider.notifier).reload(),
      ref.read(tagsProvider.notifier).reload(),
      ref.read(notificationsProvider.notifier).reload(),
    ]);
  }

  Future<void> _confirmDraft(Transaction transaction) async {
    if (!_startDraftAction(transaction.id)) {
      return;
    }
    try {
      await ref
          .read(transactionsProvider.notifier)
          .confirmTransaction(transaction.id);
      await Future.wait([
        ref.read(walletsProvider.notifier).reload(),
        ref.read(budgetsProvider.notifier).reload(),
        ref.read(goalsProvider.notifier).reload(),
        ref.read(notificationsProvider.notifier).reload(),
      ]);
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

class _ImportResultCard extends StatelessWidget {
  const _ImportResultCard({
    required this.result,
    required this.busyDraftIds,
    required this.onEdit,
    required this.onConfirm,
    required this.onDelete,
  });

  final ImageTransactionImport result;
  final Set<String> busyDraftIds;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<Transaction> onConfirm;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    final drafts = result.createdTransactions;

    return FlowFiCard(
      color: FlowFiColors.positiveSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            drafts.isEmpty
                ? 'Đã xử lý tất cả giao dịch nháp.'
                : 'AI đã tạo nháp từ hóa đơn. Kiểm tra trước khi xác nhận.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (result.imageType != null) ...[
            const SizedBox(height: 4),
            Text('Loại ảnh: ${result.imageType}'),
          ],
          if (drafts.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final item in drafts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OcrDraftTile(
                  transaction: item.transaction,
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
    required this.isBusy,
    required this.onEdit,
    required this.onConfirm,
    required this.onDelete,
  });

  final Transaction transaction;
  final bool isBusy;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<Transaction> onConfirm;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      padding: const EdgeInsets.all(12),
      color: colors.surfaceContainerLowest.withValues(alpha: 0.78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _draftMeta(transaction),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const FlowFiStatusBadge(
                      label: 'Nháp · OCR',
                      tone: FlowFiTone.info,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                transaction.amount,
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
          if (transaction.merchantName != null ||
              transaction.description != null) ...[
            const SizedBox(height: 8),
            Text(
              transaction.merchantName ?? transaction.description!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FlowFiButton(
                label: 'Sửa',
                onPressed: isBusy ? null : () => onEdit(transaction),
                variant: FlowFiButtonVariant.outline,
                fullWidth: false,
              ),
              FlowFiButton(
                label: 'Xác nhận',
                onPressed: isBusy ? null : () => onConfirm(transaction),
                isLoading: isBusy,
                fullWidth: false,
              ),
              FlowFiButton(
                label: 'Xóa',
                onPressed: isBusy ? null : () => onDelete(transaction),
                variant: FlowFiButtonVariant.ghost,
                fullWidth: false,
              ),
            ],
          ),
        ],
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
    createdTransactions: result.createdTransactions
        .where((item) => item.transaction.id != transactionId)
        .toList(growable: false),
  );
}

String _draftMeta(Transaction transaction) {
  final date = transaction.date;
  final dateLabel = date == null
      ? 'Không có ngày'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  return '$dateLabel · Nháp · OCR';
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
