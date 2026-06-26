import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);

    return wallets.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => FlowFiCard(
        color: const Color(0xFFFFF6EB),
        child: Row(
          children: [
            const Expanded(child: Text('Could not load wallets.')),
            TextButton(
              onPressed: () => ref.read(walletsProvider.notifier).reload(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: _buildContent,
    );
  }

  Widget _buildContent(List<Wallet> wallets) {
    if (wallets.isEmpty) {
      return const FlowFiCard(
        color: Color(0xFFFFF6EB),
        child: Text('Create a wallet before scanning receipts.'),
      );
    }

    _walletId ??= wallets.first.id;
    final result = _result;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _walletId,
          decoration: const InputDecoration(labelText: 'Wallet'),
          items: [
            for (final wallet in wallets)
              DropdownMenuItem(value: wallet.id, child: Text(wallet.name)),
          ],
          onChanged: _isSubmitting
              ? null
              : (value) => setState(() => _walletId = value),
        ),
        const SizedBox(height: 12),
        const FlowFiCard(
          color: Color(0xFFFFF6EB),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Scanning an image creates confirmed transactions immediately.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('Take photo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image_rounded),
                label: const Text('Choose image'),
              ),
            ),
          ],
        ),
        if (_image != null) ...[
          const SizedBox(height: 12),
          FlowFiCard(
            color: const Color(0xFFFFF6EB),
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
                        color: const Color(0xFFE7E5DC),
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
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.document_scanner_rounded),
            label: Text(_isSubmitting ? 'Scanning...' : 'Scan image'),
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 16),
          _ImportResultCard(result: result),
        ],
      ],
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
        ref.read(walletsProvider.notifier).reload(),
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
          _errorMessage = 'Could not scan this image. Please try again.';
          _isSubmitting = false;
        });
      }
    }
  }
}

class _ImportResultCard extends StatelessWidget {
  const _ImportResultCard({required this.result});

  final ImageTransactionImport result;

  @override
  Widget build(BuildContext context) {
    final count = result.createdTransactions.length;

    return FlowFiCard(
      color: const Color(0xFFE7F1DA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Created $count confirmed transaction${count == 1 ? '' : 's'}.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (result.imageType != null) ...[
            const SizedBox(height: 4),
            Text('Image type: ${result.imageType}'),
          ],
          const SizedBox(height: 10),
          for (final item in result.createdTransactions.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.transaction.amount),
                ],
              ),
            ),
        ],
      ),
    );
  }
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
