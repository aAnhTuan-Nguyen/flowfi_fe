import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../routes/app_router.dart';
import '../../../core/widgets/budget_category_card.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/goal_card.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/primary_button.dart';

/// Budget & Goals screen — budget health, categories, saving goals, gamification
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _budgets = [];
  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(budgetRepositoryProvider);
      final results = await Future.wait([
        repo.getBudgets(),
        repo.getGoals(),
      ]);

      if (mounted) {
        setState(() {
          _budgets = results[0];
          _goals = results[1];
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalSpent = _budgets.fold<double>(
      0.0,
      (sum, b) => sum + ((b['spentAmount'] as num?)?.toDouble() ?? 0.0),
    );
    final totalLimit = _budgets.fold<double>(
      0.0,
      (sum, b) => sum + ((b['limitAmount'] as num?)?.toDouble() ?? 0.0),
    );
    final remaining = (totalLimit - totalSpent).clamp(0.0, double.infinity);
    final progress =
        totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Budget & Goals',
          style:
              (Theme.of(context).textTheme.headlineMedium ?? const TextStyle())
                  .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _buildBudgetHeader(remaining),
            const SizedBox(height: 16),
            _buildBudgetProgressCard(totalSpent, totalLimit, progress),
            const SizedBox(height: 16),
            _buildCategoryGrid(),
            const SizedBox(height: 24),
            _buildSavingGoalsSection(),
            const SizedBox(height: 24),
            _buildGamificationSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(AppRoutes.createBudget);
          if (result == true) _loadData();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetHeader(double remaining) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Overview',
              style:
                  (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
                      .copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Budget Health',
              style: (Theme.of(context).textTheme.headlineLarge ??
                      const TextStyle())
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Remaining',
              style:
                  (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
                      .copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '\$${remaining.toStringAsFixed(2)}',
              style: (Theme.of(context).textTheme.headlineMedium ??
                      const TextStyle())
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetProgressCard(double spent, double limit, double progress) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Spent',
                style: (Theme.of(context).textTheme.bodyMedium ??
                        const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$${spent.toStringAsFixed(2)}',
                      style: (Theme.of(context).textTheme.titleMedium ??
                              const TextStyle())
                          .copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: ' / \$${limit.toStringAsFixed(2)}',
                      style: (Theme.of(context).textTheme.bodyMedium ??
                              const TextStyle())
                          .copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(
            value: progress,
            color: Theme.of(context).colorScheme.primaryContainer,
            height: 12,
            showGlow: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.trending_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Keep tracking your expenses to stay healthy.',
                style: (Theme.of(context).textTheme.labelSmall ??
                        const TextStyle())
                    .copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_budgets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No budgets found.')),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: _budgets.map((b) {
        final limit = (b['limitAmount'] as num?)?.toDouble() ?? 1.0;
        final spent = (b['spentAmount'] as num?)?.toDouble() ?? 0.0;
        final usagePercent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
        final isWarning = usagePercent > 0.8;

        return BudgetCategoryCard(
          category: b['categoryId'] ?? 'General',
          usagePercent: usagePercent,
          iconData: Icons.category,
          iconColor: isWarning
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          iconBgColor: isWarning
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          isWarning: isWarning,
        );
      }).toList(),
    );
  }

  Widget _buildSavingGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saving Goals',
              style: (Theme.of(context).textTheme.headlineLarge ??
                      const TextStyle())
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: Text(
                'View All',
                style: (Theme.of(context).textTheme.labelMedium ??
                        const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_goals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No saving goals found.')),
          )
        else
          SizedBox(
            height: 210,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _goals.map((g) {
                final target = (g['targetAmount'] as num?)?.toDouble() ?? 1.0;
                final current = (g['currentAmount'] as num?)?.toDouble() ?? 0.0;
                final progress =
                    target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GoalCard(
                    goalName: g['name'] ?? 'Goal',
                    currentAmount: '\$${current.toStringAsFixed(0)}',
                    targetAmount: '\$${target.toStringAsFixed(0)}',
                    progress: progress,
                    iconData: Icons.savings_outlined,
                    progressColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    iconBgColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.15),
                    badgeLabel: 'Active',
                    badgeColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    badgeTextColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildGamificationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.military_tech,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points & Badges',
                      style: (Theme.of(context).textTheme.headlineMedium ??
                              const TextStyle())
                          .copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "You're in the top 5% of savers this week!",
                      style: (Theme.of(context).textTheme.bodyMedium ??
                              const TextStyle())
                          .copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '2,450',
                      style: (Theme.of(context).textTheme.displayLarge ??
                              const TextStyle())
                          .copyWith(
                              color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                      'TOTAL POINTS',
                      style: (Theme.of(context).textTheme.labelSmall ??
                              const TextStyle())
                          .copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )
                          .copyWith(letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 20),
              _buildBadgeStack(),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Redeem Rewards',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStack() {
    final badges = [
      (
        color: Theme.of(context).colorScheme.secondaryContainer,
        icon: Icons.star
      ),
      (
        color: Theme.of(context).colorScheme.tertiaryContainer,
        icon: Icons.bolt
      ),
      (
        color: Theme.of(context).colorScheme.primaryContainer,
        icon: Icons.emoji_events
      ),
    ];

    return Row(
      children: [
        ...badges.map(
          (b) => Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(left: -8),
            decoration: BoxDecoration(
              color: b.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(b.icon, color: Colors.white, size: 16),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(left: -8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              '+4',
              style:
                  (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
                      .copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
