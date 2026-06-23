import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_router.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/transaction_tile.dart';

/// Transaction History screen — search, filter chips, grouped list
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  static const _filters = ['All', 'Date', 'Type', 'Wallet'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final transactions = await repo.getTransactions();
      if (mounted) {
        setState(() {
          _transactions = transactions;
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
    _searchController.dispose();
    super.dispose();
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
          'Transaction History',
          style: AppTextStyles.headlineMd(color: context.colors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.tune_outlined, color: context.colors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _buildSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _buildFilterChips(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: _transactions.isEmpty
                        ? const Center(child: Text('No transactions found.'))
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 16),
                            children: [
                              _buildGroupHeader('ALL TRANSACTIONS'),
                              GlassCard(
                                padding: EdgeInsets.zero,
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: _transactions.map((t) {
                                    final isExpense = t['type'] == 'EXPENSE';
                                    return TransactionTile(
                                      merchantName: t['tag']?['name'] ?? 'Unknown',
                                      timestamp: t['date'] ?? 'Unknown date',
                                      amount: '\$${t['amount']}',
                                      isExpense: isExpense,
                                      iconData: Icons.receipt_long,
                                      category: t['tag']?['name'] ?? 'General',
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addTransaction),
        backgroundColor: context.colors.primary,
        child: Icon(Icons.add, color: context.colors.onPrimary),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMd(color: context.colors.onSurface),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: AppTextStyles.bodyMd(color: context.colors.outline),
          prefixIcon: Icon(
            Icons.search,
            color: context.colors.outline,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(_searchController.clear),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.outlineVariant,
                ),
              ),
              child: Text(
                _filters[i],
                style: AppTextStyles.labelMd(
                  color: isSelected
                      ? context.colors.onPrimary
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label,
        style: AppTextStyles.labelSm(
          color: context.colors.onSurfaceVariant,
        ).copyWith(letterSpacing: 1.5),
      ),
    );
  }
}
