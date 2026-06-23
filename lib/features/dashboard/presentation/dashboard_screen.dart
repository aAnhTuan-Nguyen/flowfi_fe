import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_router.dart';
import '../../../core/widgets/balance_card.dart';
import '../../../core/widgets/flowfi_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../core/widgets/charts/weekly_bar_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _summary;
  List<double>? _weeklySpending;
  List<Map<String, dynamic>>? _transactions;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dashboardRepo = ref.read(dashboardRepositoryProvider);
      final transactionRepo = ref.read(transactionRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      final results = await Future.wait([
        dashboardRepo.getSummary(),
        dashboardRepo.getWeeklySpending(),
        transactionRepo.getTransactions(),
        profileRepo.getProfile(),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as Map<String, dynamic>;
          _weeklySpending = results[1] as List<double>;
          _transactions = results[2] as List<Map<String, dynamic>>;
          _profile = results[3] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final balance = _summary?['balance'] ?? 0.0;
    final income = _summary?['income'] ?? 0.0;
    final expenses = _summary?['expense'] ?? 0.0;

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: FlowFiAppBar(
        showAvatar: true,
        userName: _profile?['fullName']?.toString().split(' ').first ?? 'User',
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            bottom: 100,
          ),
          children: [
            const _GreetingBadge(),
            const SizedBox(height: 20),
            BalanceCard(
              totalBalance: '\$${balance.toStringAsFixed(2)}',
              income: '\$${income.toStringAsFixed(2)}',
              expenses: '\$${expenses.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 20),
            _buildBudgetWarning(context),
            const SizedBox(height: 20),
            _buildWeeklyChart(_weeklySpending),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Recent Transactions',
              actionLabel: 'See All',
              onAction: () => context.push(AppRoutes.transactions),
            ),
            const SizedBox(height: 12),
            _buildRecentTransactions(context, _transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetWarning(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: context.colors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Budget Warning',
                  style: AppTextStyles.bodySemibold(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.budget),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'View Budget',
                  style: AppTextStyles.labelMd(color: context.colors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Food & Dining is at 88% of your monthly budget.',
            style: AppTextStyles.bodyMd(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ProgressBar(
            value: 0.88,
            color: context.colors.error,
            height: 6,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r'$880 / $1,000',
                style: AppTextStyles.labelSm(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(
                '88% used',
                style: AppTextStyles.labelSm(color: context.colors.error)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<double>? weeklySpending) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY SPENDING',
                    style: AppTextStyles.labelSm(
                      color: context.colors.onSurfaceVariant,
                    ).copyWith(letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weeklySpending != null ? '\$${weeklySpending.reduce((a, b) => a + b).toStringAsFixed(2)}' : '\$0.00',
                    style: AppTextStyles.headlineMd(color: context.colors.onSurface),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: context.colors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '-0%',
                      style: AppTextStyles.labelSm(color: context.colors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          WeeklyBarChart(
            values: weeklySpending ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            activeIndex: 3,
            labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<Map<String, dynamic>>? transactions) {
    if (transactions == null || transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text('No transactions found')),
      );
    }
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: transactions.map((t) {
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
    );
  }
}

class _GreetingBadge extends StatelessWidget {
  const _GreetingBadge();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              const Text('👋', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                greeting,
                style: AppTextStyles.labelMd(color: context.colors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
