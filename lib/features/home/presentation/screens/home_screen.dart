import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../routes/app_routes.dart';
import '../../../ai_processing/presentation/widgets/image_transaction_import_sheet.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../budgets/presentation/providers/budgets_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../tags/presentation/widgets/tag_manager_sheet.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/presentation/widgets/transaction_entry_sheet.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).value;
    final wallets = ref.watch(walletsProvider);
    final transactions = ref.watch(transactionsProvider);
    final budgets = ref.watch(budgetsProvider);
    final currency = auth?.user?.currencyCode ?? 'VND';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(walletsProvider.notifier).reload(),
            ref.read(transactionsProvider.notifier).reload(),
            ref.read(budgetsProvider.notifier).reload(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(user: auth?.user, ref: ref),
              const SizedBox(height: 18),
              _BalanceOverview(wallets: wallets, currency: currency),
              const SizedBox(height: 12),
              _MonthSnapshot(transactions: transactions, currency: currency),
              const SizedBox(height: 14),
              _QuickActions(),
              const SizedBox(height: 18),
              _SpendingChartCard(transactions: transactions),
              const SizedBox(height: 18),
              _InsightNudge(transactions: transactions),
              const SizedBox(height: 18),
              _RecentTransactions(
                transactions: transactions,
                currency: currency,
              ),
              const SizedBox(height: 18),
              _BudgetHealthCard(budgets: budgets, currency: currency),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.user, required this.ref});

  final AuthUser? user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = _firstName(user?.fullName);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.person_rounded, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, $name',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Hôm nay mình xem tiền thật nhanh.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Thông báo',
        ),
        PopupMenuButton<_AccountAction>(
          tooltip: 'Tài khoản',
          icon: const Icon(Icons.account_circle_outlined),
          onSelected: (action) async {
            switch (action) {
              case _AccountAction.editProfile:
                await showFlowFiFormSheet<void>(
                  context: context,
                  title: 'Hồ sơ cá nhân',
                  child: _ProfileEditSheet(user: user),
                );
                break;
              case _AccountAction.signOut:
                final confirmed = await confirmDestructiveAction(
                  context,
                  title: 'Đăng xuất?',
                  message: 'Bạn cần đăng nhập lại để tiếp tục dùng FlowFi.',
                  actionLabel: 'Đăng xuất',
                );
                if (!confirmed || !context.mounted) {
                  return;
                }
                try {
                  await ref.read(authControllerProvider.notifier).signOut();
                } catch (_) {
                  if (context.mounted) {
                    showGenericMutationError(context);
                  }
                }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _AccountAction.editProfile,
              child: Text('Chỉnh sửa hồ sơ'),
            ),
            PopupMenuItem(
              value: _AccountAction.signOut,
              child: Text('Đăng xuất'),
            ),
          ],
        ),
      ],
    );
  }
}

enum _AccountAction { editProfile, signOut }

class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet({required this.user});

  final AuthUser? user;

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _currencyCodeController;
  late final TextEditingController _monthlyBudgetLimitController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.user?.fullName ?? '',
    );
    _currencyCodeController = TextEditingController(
      text: widget.user?.currencyCode ?? 'VND',
    );
    _monthlyBudgetLimitController = TextEditingController(
      text: widget.user?.monthlyBudgetLimit ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _currencyCodeController.dispose();
    _monthlyBudgetLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Họ tên'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _currencyCodeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Tiền tệ'),
            validator: (value) {
              final normalized = value?.trim();
              if (normalized == null || normalized.isEmpty) {
                return 'Nhập mã tiền tệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _monthlyBudgetLimitController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Hạn mức tháng'),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu hồ sơ'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final fullName = _fullNameController.text.trim();
      final currencyCode = _currencyCodeController.text.trim().toUpperCase();
      final monthlyBudgetLimit = _monthlyBudgetLimitController.text.trim();
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(
            fullName: fullName.isEmpty ? null : fullName,
            currencyCode: currencyCode.isEmpty ? 'VND' : currencyCode,
            monthlyBudgetLimit: monthlyBudgetLimit.isEmpty
                ? null
                : monthlyBudgetLimit,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _BalanceOverview extends StatelessWidget {
  const _BalanceOverview({required this.wallets, required this.currency});

  final AsyncValue<List<Wallet>> wallets;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return wallets.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải số dư'),
      error: (_, _) => const FlowFiCard(child: Text('Không tải được ví.')),
      data: (items) {
        final total = items.fold<BigInt>(
          BigInt.zero,
          (sum, wallet) => sum + _parseWholeAmount(wallet.balance),
        );
        Wallet? defaultWallet;
        for (final wallet in items) {
          if (wallet.isDefault) {
            defaultWallet = wallet;
            break;
          }
        }

        return FlowFiCard(
          color: colors.primary,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng số dư',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.76),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatMoney(total, currency),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colors.onPrimary.withValues(alpha: 0.88),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      defaultWallet == null
                          ? '${items.length} ví đang theo dõi'
                          : 'Mặc định: ${defaultWallet.name}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.88),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthSnapshot extends StatelessWidget {
  const _MonthSnapshot({required this.transactions, required this.currency});

  final AsyncValue<List<Transaction>> transactions;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return transactions.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        final monthlyExpenses = items
            .where(
              (transaction) =>
                  transaction.type == MoneyFlowType.expense &&
                  transaction.status == TransactionStatus.confirmed &&
                  _isSameMonth(transaction.date, now),
            )
            .fold<BigInt>(
              BigInt.zero,
              (sum, transaction) => sum + _parseWholeAmount(transaction.amount),
            );
        final monthlyIncome = items
            .where(
              (transaction) =>
                  transaction.type == MoneyFlowType.income &&
                  transaction.status == TransactionStatus.confirmed &&
                  _isSameMonth(transaction.date, now),
            )
            .fold<BigInt>(
              BigInt.zero,
              (sum, transaction) => sum + _parseWholeAmount(transaction.amount),
            );

        return Row(
          children: [
            Expanded(
              child: _MiniMetricCard(
                label: 'Chi tiêu tháng này',
                value: _formatMoney(monthlyExpenses, currency),
                icon: Icons.trending_down_rounded,
                tone: _MetricTone.expense,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniMetricCard(
                label: 'Thu nhập tháng này',
                value: _formatMoney(monthlyIncome, currency),
                icon: Icons.trending_up_rounded,
                tone: _MetricTone.income,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.document_scanner_outlined,
            label: 'Quét',
            onTap: () => showFlowFiFormSheet<void>(
              context: context,
              title: 'Quét hóa đơn',
              child: const ImageTransactionImportSheet(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.mic_none_rounded,
            label: 'Voice',
            onTap: () => showFlowFiFormSheet<void>(
              context: context,
              title: 'Nói giao dịch',
              child: const VoiceTransactionPlaceholder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.sell_outlined,
            label: 'Danh mục',
            onTap: () => showFlowFiFormSheet<void>(
              context: context,
              title: 'Quản lý danh mục',
              child: const TagManagerSheet(),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: colors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendingChartCard extends StatelessWidget {
  const _SpendingChartCard({required this.transactions});

  final AsyncValue<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    return transactions.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải biểu đồ'),
      error: (_, _) => const FlowFiCard(child: Text('Không tải được biểu đồ.')),
      data: (items) {
        final confirmed = items
            .where(
              (transaction) =>
                  transaction.status == TransactionStatus.confirmed,
            )
            .toList(growable: false);
        final income = _sumByType(confirmed, MoneyFlowType.income);
        final expense = _sumByType(confirmed, MoneyFlowType.expense);
        final hasData = income > BigInt.zero || expense > BigInt.zero;

        if (!hasData) {
          return const FlowFiInlineEmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Chưa có dữ liệu biểu đồ',
            message: 'Thêm giao dịch đầu tiên để xem tỷ lệ thu chi.',
          );
        }

        return FlowFiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dòng tiền',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.insights_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 36,
                          borderData: FlBorderData(show: false),
                          sections: [
                            if (expense > BigInt.zero)
                              _chartSection(
                                context,
                                value: expense,
                                title: 'Chi',
                                color: const Color(0xFFB84A3F),
                              ),
                            if (income > BigInt.zero)
                              _chartSection(
                                context,
                                value: income,
                                title: 'Thu',
                                color: const Color(0xFF4F6F39),
                              ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendRow(
                            color: const Color(0xFFB84A3F),
                            label: 'Chi tiêu',
                            value: _compactAmount(expense),
                          ),
                          const SizedBox(height: 10),
                          _LegendRow(
                            color: const Color(0xFF4F6F39),
                            label: 'Thu nhập',
                            value: _compactAmount(income),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InsightNudge extends StatelessWidget {
  const _InsightNudge({required this.transactions});

  final AsyncValue<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      color: colors.surfaceContainerLow,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: transactions.when(
              loading: () => const Text('AI đang chờ dữ liệu giao dịch.'),
              error: (_, _) => const Text('AI sẽ gợi ý khi dữ liệu sẵn sàng.'),
              data: (items) => Text(
                items.any((item) => item.status == TransactionStatus.draft)
                    ? 'Có giao dịch nháp cần bạn kiểm tra trước khi tính vào báo cáo.'
                    : 'Scan và voice sẽ tạo gợi ý, bạn vẫn là người xác nhận cuối cùng.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({
    required this.transactions,
    required this.currency,
  });

  final AsyncValue<List<Transaction>> transactions;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return transactions.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải giao dịch'),
      error: (_, _) =>
          const FlowFiCard(child: Text('Không tải được giao dịch.')),
      data: (items) {
        if (items.isEmpty) {
          return const FlowFiInlineEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'Chưa có giao dịch',
            message: 'Nhấn dấu cộng để nhập nhanh, scan hoặc dùng voice.',
          );
        }

        final sorted = [...items]
          ..sort((a, b) {
            final left = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
            final right = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
            return right.compareTo(left);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Giao dịch gần đây',
              actionLabel: 'Xem tất cả',
              onActionPressed: () => context.go(AppRoutes.transactions),
            ),
            const SizedBox(height: 10),
            for (final transaction in sorted.take(3)) ...[
              _TransactionTile(transaction: transaction, currency: currency),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _BudgetHealthCard extends StatelessWidget {
  const _BudgetHealthCard({required this.budgets, required this.currency});

  final AsyncValue<List<Budget>> budgets;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return budgets.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải ngân sách'),
      error: (_, _) =>
          const FlowFiCard(child: Text('Không tải được ngân sách.')),
      data: (items) {
        if (items.isEmpty) {
          return const FlowFiInlineEmptyState(
            icon: Icons.savings_outlined,
            title: 'Chưa có ngân sách',
            message: 'Tạo ngân sách để biết khoản nào đang gần chạm giới hạn.',
          );
        }

        return FlowFiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngân sách nổi bật',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              for (final budget in items.take(2)) ...[
                _BudgetProgress(budget: budget, currency: currency),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final toneColor = tone == _MetricTone.income
        ? const Color(0xFF4F6F39)
        : const Color(0xFFB84A3F);

    return FlowFiCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: toneColor, size: 20),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

enum _MetricTone { income, expense }

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(onPressed: onActionPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.currency});

  final Transaction transaction;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == MoneyFlowType.income;
    final colors = Theme.of(context).colorScheme;
    final toneColor = isIncome
        ? const Color(0xFF4F6F39)
        : const Color(0xFFB84A3F);
    final amount = _formatMoney(
      _parseWholeAmount(transaction.amount),
      currency,
    );

    return FlowFiCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: toneColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: toneColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _transactionMeta(transaction),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'}$amount',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: toneColor),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.budget, required this.currency});

  final Budget budget;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final threshold = budget.warningThresholdPercent.clamp(0, 100);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                budget.tagName ?? 'Ngân sách',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            Text(
              _formatMoney(_parseWholeAmount(budget.amount), currency),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: threshold / 100,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation(
              threshold >= 80
                  ? const Color(0xFFC9872B)
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

PieChartSectionData _chartSection(
  BuildContext context, {
  required BigInt value,
  required String title,
  required Color color,
}) {
  return PieChartSectionData(
    value: value.toDouble(),
    title: title,
    radius: 44,
    color: color,
    titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
    ),
  );
}

BigInt _sumByType(List<Transaction> transactions, MoneyFlowType type) {
  return transactions
      .where((transaction) => transaction.type == type)
      .fold<BigInt>(
        BigInt.zero,
        (sum, transaction) => sum + _parseWholeAmount(transaction.amount),
      );
}

BigInt _parseWholeAmount(String value) {
  final normalized = value.trim().replaceAll(',', '');
  final match = RegExp(r'^-?\d+').firstMatch(normalized);
  if (match == null) {
    return BigInt.zero;
  }
  return BigInt.tryParse(match.group(0)!) ?? BigInt.zero;
}

String _formatMoney(BigInt value, String currency) {
  final negative = value < BigInt.zero;
  final digits = (negative ? -value : value).toString();
  final grouped = _groupDigits(digits);
  return '${negative ? '-' : ''}$grouped $currency';
}

String _compactAmount(BigInt value) {
  if (value >= BigInt.from(1000000)) {
    final millions = value ~/ BigInt.from(1000000);
    return '${millions}m';
  }
  if (value >= BigInt.from(1000)) {
    final thousands = value ~/ BigInt.from(1000);
    return '${thousands}k';
  }
  return value.toString();
}

String _groupDigits(String digits) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _firstName(String? name) {
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return 'bạn';
  }
  return trimmed.split(RegExp(r'\s+')).first;
}

bool _isSameMonth(DateTime? date, DateTime now) {
  return date != null && date.month == now.month && date.year == now.year;
}

String _transactionMeta(Transaction transaction) {
  final date = transaction.date;
  final dateLabel = date == null
      ? 'Không có ngày'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  final status = switch (transaction.status) {
    TransactionStatus.draft => 'Nháp',
    TransactionStatus.confirmed => 'Đã xác nhận',
    TransactionStatus.unknown => 'Không rõ',
  };
  return '$dateLabel · $status';
}
