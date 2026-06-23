import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';


import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/tag_chip.dart';

/// AI Review Screen — shows auto-filled transaction fields after scanning receipt
class AiReviewScreen extends ConsumerStatefulWidget {
  const AiReviewScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  ConsumerState<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends ConsumerState<AiReviewScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _reviewData;
  List<Map<String, dynamic>> _wallets = [];
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final walletRepo = ref.read(walletRepositoryProvider);
      
      final results = await Future.wait([
        repo.getAiReview(widget.imagePath),
        walletRepo.getWallets(),
      ]);

      if (mounted) {
        setState(() {
          _reviewData = results[0] as Map<String, dynamic>;
          _wallets = (results[1] as List).cast<Map<String, dynamic>>();
          if (_wallets.isNotEmpty) {
            _selectedWalletId = _wallets.first['id'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a wallet')),
      );
      return;
    }

    final parsedData = _reviewData?['parsedData'];
    if (parsedData == null) return;

    final amountStr = parsedData['amount']?.toString() ?? '0';
    final amount = double.tryParse(amountStr) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final tagsRepo = ref.read(tagRepositoryProvider);
      final tags = await tagsRepo.getTags();
      
      final aiTagType = parsedData['tag']?.toString().toUpperCase() ?? '';
      String? tagId;
      try {
        tagId = tags.firstWhere((t) => (t['type']?.toString().toUpperCase() == aiTagType) || (t['name']?.toString().toUpperCase() == aiTagType))['id'];
      } catch (_) {
        if (tags.isNotEmpty) tagId = tags.first['id'];
      }

      await repo.createTransaction({
        'walletId': _selectedWalletId,
        'tagId': tagId,
        'amount': amount,
        'type': parsedData['transactionType'] ?? 'EXPENSE',
        'title': 'AI Scan: ${parsedData['tag'] ?? 'Transaction'}',
        'note': parsedData['rawText'] ?? 'Extracted from receipt',
        'source': 'AI',
      });
      if (mounted) {
        context.pop();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Review',
          style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConfidenceCard(),
                    const SizedBox(height: 20),
                    _buildReceiptPreview(),
                    const SizedBox(height: 20),
                    _buildReviewedFields(),
                    const SizedBox(height: 24),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            label: 'Confirm & Save',
                            onPressed: _saveTransaction,
                            icon: Icons.check_circle_outline,
                          ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Edit Manually',
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final confidenceScore = _reviewData?['confidenceScore'] ?? 98;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Confidence Score',
                  style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$confidenceScore%',
                      style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle()).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        confidenceScore > 85 ? 'HIGH' : 'LOW',
                        style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.primary)
                            .copyWith(letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreview() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanned Receipt',
                  style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '1 page scanned',
                  style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(16),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            ? Image.network(widget.imagePath, fit: BoxFit.contain)
                            : Image.file(File(widget.imagePath), fit: BoxFit.contain),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text(
              'View',
              style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewedFields() {
    final parsedData = _reviewData?['parsedData'];
    final amount = parsedData?['amount']?.toString() ?? '0.00';
    final type = parsedData?['transactionType'] ?? 'N/A';
    final aiTag = parsedData?['tag'] ?? 'UNKNOWN';
    
    String dateStr = 'N/A';
    if (parsedData?['transactionDate'] != null) {
      try {
        final dt = DateTime.parse(parsedData!['transactionDate']);
        dateStr = DateFormat('MMM dd, yyyy - HH:mm').format(dt);
      } catch (_) {
        dateStr = parsedData!['transactionDate'].toString();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviewed Fields',
          style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ReviewField(
                label: 'Type',
                value: type,
                icon: Icons.swap_horiz,
              ),
              Divider(height: 24, color: Theme.of(context).colorScheme.outlineVariant),
              _ReviewField(
                label: 'Amount',
                value: '\$$amount',
                icon: Icons.attach_money,
                valueColor: Theme.of(context).colorScheme.error,
              ),
              Divider(height: 24, color: Theme.of(context).colorScheme.outlineVariant),
              _ReviewField(
                label: 'Date',
                value: dateStr,
                icon: Icons.access_time,
              ),
              Divider(height: 24, color: Theme.of(context).colorScheme.outlineVariant),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet',
                    style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedWalletId,
                        isExpanded: true,
                        style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Theme.of(context).colorScheme.onSurface),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        items: _wallets.map((w) {
                          return DropdownMenuItem<String>(
                            value: w['id'],
                            child: Text(w['name'] ?? 'Unknown Wallet'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedWalletId = v),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: Theme.of(context).colorScheme.outlineVariant),
              Row(
                children: [
                  Icon(
                    Icons.label_outline,
                    color: Theme.of(context).colorScheme.outline,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            TagChip(label: '$aiTag', selected: true),
                            const TagChip(label: 'AI-Extracted', selected: false),
                          ],
                        ),
                      ],
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
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.outline, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primaryContainer,
          size: 20,
        ),
      ],
    );
  }
}
