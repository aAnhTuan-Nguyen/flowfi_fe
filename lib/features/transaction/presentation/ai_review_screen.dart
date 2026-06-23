import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
  Map<String, dynamic>? _reviewData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final data = await repo.getAiReview(widget.imagePath);
      if (mounted) {
        setState(() {
          _reviewData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: context.colors.primary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Review',
          style: AppTextStyles.headlineMd(color: context.colors.primary),
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
                    PrimaryButton(
                      label: 'Confirm & Save',
                      onPressed: () {
                        context.pop();
                        context.pop();
                      },
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Edit Manually',
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: context.colors.onSurface,
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
              color: context.colors.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: context.colors.primary,
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
                  style: AppTextStyles.labelMd(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$confidenceScore%',
                      style: AppTextStyles.headlineMd(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        confidenceScore > 85 ? 'HIGH' : 'LOW',
                        style: AppTextStyles.labelSm(color: context.colors.primary)
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
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: context.colors.primary,
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
                  style: AppTextStyles.bodySemibold(
                    color: context.colors.onSurface,
                  ),
                ),
                Text(
                  '1 page scanned',
                  style: AppTextStyles.labelSm(
                    color: context.colors.onSurfaceVariant,
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
              style: AppTextStyles.labelMd(color: context.colors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewedFields() {
    final amount = _reviewData?['extractedData']?['amount']?.toString() ?? '0.00';
    final merchant = _reviewData?['extractedData']?['merchantName'] ?? 'N/A';
    final category = _reviewData?['extractedData']?['category'] ?? 'N/A';
    final dateStr = _reviewData?['extractedData']?['date'] ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviewed Fields',
          style: AppTextStyles.headlineMd(color: context.colors.onSurface),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ReviewField(
                label: 'Merchant',
                value: merchant,
                icon: Icons.store_outlined,
              ),
              Divider(height: 24, color: context.colors.outlineVariant),
              _ReviewField(
                label: 'Amount',
                value: '\$$amount',
                icon: Icons.attach_money,
                valueColor: context.colors.expense,
              ),
              Divider(height: 24, color: context.colors.outlineVariant),
              _ReviewField(
                label: 'Category',
                value: category,
                icon: Icons.restaurant,
              ),
              Divider(height: 24, color: context.colors.outlineVariant),
              _ReviewField(
                label: 'Date',
                value: dateStr,
                icon: Icons.access_time,
              ),
              Divider(height: 24, color: context.colors.outlineVariant),
              const _ReviewField(
                label: 'Wallet',
                value: 'Cash Wallet',
                icon: Icons.account_balance_wallet_outlined,
              ),
              Divider(height: 24, color: context.colors.outlineVariant),
              Row(
                children: [
                  Icon(
                    Icons.label_outline,
                    color: context.colors.outline,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: AppTextStyles.labelSm(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Wrap(
                          spacing: 6,
                          children: [
                            TagChip(label: 'AI-Extracted', selected: true),
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
        Icon(icon, color: context.colors.outline, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSm(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySemibold(
                  color: valueColor ?? context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle,
          color: context.colors.primaryContainer,
          size: 20,
        ),
      ],
    );
  }
}
