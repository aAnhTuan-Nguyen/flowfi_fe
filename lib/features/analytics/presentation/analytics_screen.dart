  import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/flowfi_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/segmented_tab_bar.dart';
import '../../../core/widgets/charts/cash_flow_bar_chart.dart';
import '../../../core/widgets/charts/spending_donut_chart.dart';

/// Analytics & Reports screen
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _timePeriod = 2; // 0=Day, 1=Week, 2=Month, 3=Year
  bool _isLoading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dashboardRepo = ref.read(dashboardRepositoryProvider);
      final analyticsRepo = ref.read(analyticsRepositoryProvider);
      final periodString = _timePeriod == 0 ? 'day' : _timePeriod == 1 ? 'week' : _timePeriod == 2 ? 'month' : 'year';
      
      final results = await Future.wait([
        dashboardRepo.getSummary(),
        analyticsRepo.getCategoryBreakdown(period: periodString),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as Map<String, dynamic>;
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
    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: const FlowFiAppBar(title: 'FlowFi'),
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 80,
          left: 20,
          right: 20,
          bottom: 100,
        ),
        children: [
          SegmentedTabBar(
            tabs: const ['Day', 'Week', 'Month', 'Year'],
            selectedIndex: _timePeriod,
            onTabChanged: (i) {
              setState(() {
                _timePeriod = i;
                _isLoading = true;
              });
              _loadData();
            },
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildAiInsightsCard(),
            const SizedBox(height: 20),
            _buildCashFlowCard(),
            const SizedBox(height: 20),
            _buildSpendingBreakdown(),
            const SizedBox(height: 20),
            _buildMonthlyBreakdownTable(),
          ],
        ],
      ),
    );
  }

  Widget _buildAiInsightsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    color: context.colors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Insights',
                    style: AppTextStyles.headlineMd(color: context.colors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InsightRow(
                icon: Icons.info_outline,
                color: context.colors.primary,
                bgColor: context.colors.primaryContainer,
                text: 'No AI insights available for this period. ',
                highlight: 'Try another period',
                rest: ' or add more transactions.',
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.auto_awesome,
                size: 80,
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowCard() {
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
                    'CASH FLOW',
                    style: AppTextStyles.labelSm(
                      color: context.colors.onSurfaceVariant,
                    ).copyWith(letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _summary?['balance'] != null ? '\$${_summary!['balance']}' : '\$0.00',
                        style:
                            AppTextStyles.headlineLg(color: context.colors.onSurface),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '0%',
                        style: AppTextStyles.labelSm(color: context.colors.primary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _LegendDot(color: context.colors.primary, label: 'Income'),
                  const SizedBox(width: 12),
                  _LegendDot(color: context.colors.secondary, label: 'Expense'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const CashFlowBarChart(
            incomeValues: [0.0, 0.0, 0.0, 0.0],
            expenseValues: [0.0, 0.0, 0.0, 0.0],
            labels: ['W1', 'W2', 'W3', 'W4'],
            activeIndex: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingBreakdown() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOP SPENDING',
            style: AppTextStyles.labelSm(
              color: context.colors.onSurfaceVariant,
            ).copyWith(letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SpendingDonutChart(
                segments: [
                  DonutSegment(
                    value: 1.0,
                    color: context.colors.surfaceContainerHigh,
                    label: 'No Data',
                  ),
                ],
                centerLabel: 'Total',
                centerValue: '\$0.00',
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _SpendingLegendRow(
                      color: context.colors.surfaceContainerHigh,
                      label: 'No Data',
                      percent: '0%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdownTable() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Breakdown',
                  style: AppTextStyles.headlineMd(color: context.colors.onSurface),
                ),
                const Row(
                  children: [
                    _ExportButton(
                      label: 'PDF',
                      icon: Icons.picture_as_pdf_outlined,
                    ),
                    SizedBox(width: 8),
                    _ExportButton(
                      label: 'Image',
                      icon: Icons.image_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No breakdown data available',
              style: AppTextStyles.bodyMd(color: context.colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.text,
    required this.highlight,
    required this.rest,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final String text;
  final String highlight;
  final String rest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMd(color: context.colors.onSurface),
                children: [
                  TextSpan(text: text),
                  TextSpan(
                    text: highlight,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  TextSpan(text: rest),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSm(color: context.colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SpendingLegendRow extends StatelessWidget {
  const _SpendingLegendRow({
    required this.color,
    required this.label,
    required this.percent,
  });

  final Color color;
  final String label;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMd(color: context.colors.onSurface),
            ),
          ],
        ),
        Text(
          percent,
          style: AppTextStyles.bodySemibold(color: context.colors.onSurface),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.colors.onSurface),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMd(color: context.colors.onSurface),
          ),
        ],
      ),
    );
  }
}

