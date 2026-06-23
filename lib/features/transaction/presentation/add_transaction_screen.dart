import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../routes/app_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/segmented_tab_bar.dart';
import '../../../core/widgets/tag_chip.dart';
import 'package:image_picker/image_picker.dart';

/// Add Transaction screen — Manual/Voice/Scan tabs, Amount, Category, Note, Tags
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  int _inputMode = 0; // 0=Manual, 1=Voice, 2=Scan
  int _type = 0; // 0=Expense, 1=Income
  final _amountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _wallets = [];
  List<Map<String, dynamic>> _tags = [];

  String? _selectedWalletId;
  String? _selectedTagId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final walletsRepo = ref.read(walletRepositoryProvider);
      final tagsRepo = ref.read(tagRepositoryProvider);

      final results = await Future.wait([
        walletsRepo.getWallets(),
        tagsRepo.getTags(),
      ]);

      if (mounted) {
        setState(() {
          _wallets = results[0];
          _tags = results[1];
          if (_wallets.isNotEmpty) {
            _selectedWalletId = _wallets.first['id'];
          }
          if (_tags.isNotEmpty) {
            _selectedTagId = _tags.first['id'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_selectedWalletId == null || _selectedTagId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select wallet and tag')),
      );
      return;
    }

    final amountStr = _amountController.text;
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
      await repo.createTransaction({
        'walletId': _selectedWalletId,
        'tagId': _selectedTagId,
        'amount': amount,
        'type': _type == 0 ? 'EXPENSE' : 'INCOME',
        'title': _tags.firstWhere((t) => t['id'] == _selectedTagId)['name'] ??
            'Transaction',
        'note': _noteController.text,
        'source': 'MANUAL',
      });
      if (mounted) {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Transaction',
          style:
              (Theme.of(context).textTheme.headlineMedium ?? const TextStyle())
                  .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: SegmentedTabBar(
                      tabs: const ['Manual', 'Voice', 'Scan'],
                      selectedIndex: _inputMode,
                      onTabChanged: (i) async {
                        setState(() => _inputMode = i);
                        if (i == 2) {
                          // Show bottom sheet to choose camera or gallery
                          final source =
                              await showModalBottomSheet<ImageSource>(
                            context: context,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    title: Text('Camera',
                                        style: (Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium ??
                                                const TextStyle())
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface)),
                                    onTap: () =>
                                        context.pop(ImageSource.camera),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo_library,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    title: Text('Gallery',
                                        style: (Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium ??
                                                const TextStyle())
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface)),
                                    onTap: () =>
                                        context.pop(ImageSource.gallery),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (source != null) {
                            final picker = ImagePicker();
                            final pickedFile =
                                await picker.pickImage(source: source);

                            if (pickedFile != null && context.mounted) {
                              context.push(
                                AppRoutes.aiReview,
                                extra: {'imagePath': pickedFile.path},
                              );
                            } else {
                              setState(() => _inputMode =
                                  0); // revert to manual if cancelled
                            }
                          } else {
                            setState(() => _inputMode =
                                0); // revert to manual if cancelled
                          }
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTypeToggle(),
                          const SizedBox(height: 20),
                          _buildAmountDisplay(),
                          const SizedBox(height: 20),
                          _buildCategoryGrid(),
                          const SizedBox(height: 20),
                          _buildWalletSelector(),
                          const SizedBox(height: 20),
                          _buildNoteField(),
                          const SizedBox(height: 28),
                          _isSaving
                              ? const Center(child: CircularProgressIndicator())
                              : PrimaryButton(
                                  label: 'Save Transaction',
                                  onPressed: _saveTransaction,
                                  icon: Icons.check,
                                ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TypeToggleButton(
            label: 'Expense',
            isSelected: _type == 0,
            color: Theme.of(context).colorScheme.error,
            onTap: () => setState(() => _type = 0),
          ),
          _TypeToggleButton(
            label: 'Income',
            isSelected: _type == 1,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () => setState(() => _type = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            'Amount',
            style:
                (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
                    .copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                r'$',
                style: (Theme.of(context).textTheme.headlineLarge ??
                        const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onTap: () {
                    if (_amountController.text == '0' ||
                        _amountController.text == '0.0' ||
                        _amountController.text == '0.00') {
                      _amountController.clear();
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  textAlign: TextAlign.center,
                  style: (Theme.of(context).textTheme.displayLarge ??
                          const TextStyle())
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_tags.isEmpty) {
      return const Text('No tags found');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category (Tag)',
              style: (Theme.of(context).textTheme.labelMedium ??
                      const TextStyle())
                  .copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.createTag),
              icon: Icon(Icons.add,
                  size: 16, color: Theme.of(context).colorScheme.primary),
              label: Text(
                'New Tag',
                style: (Theme.of(context).textTheme.labelMedium ??
                        const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            final isSelected = tag['id'] == _selectedTagId;
            return GestureDetector(
              onTap: () => setState(() => _selectedTagId = tag['id']),
              child: TagChip(
                label: tag['name'] ?? 'Tag',
                selected: isSelected,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWalletSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet',
          style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
              .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedWalletId,
              isExpanded: true,
              style:
                  (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
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
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note',
          style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
              .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 3,
          style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Add a note...',
            hintStyle:
                (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.outline),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  const _TypeToggleButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style:
                (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
                    .copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                    .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
