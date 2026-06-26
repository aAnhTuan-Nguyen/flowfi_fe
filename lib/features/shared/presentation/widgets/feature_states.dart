import 'package:flutter/material.dart';

class FlowFiFeatureScaffold extends StatelessWidget {
  const FlowFiFeatureScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.actions = const [],
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final List<Widget> actions;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        notificationPredicate: onRefresh == null ? (_) => false : (_) => true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: const Color(0xFF49672A)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF757872)),
                          ),
                        ],
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ...actions,
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: child,
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showFlowFiFormSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return FlowFiFormSheet(title: title, child: child);
    },
  );
}

class FlowFiFormSheet extends StatelessWidget {
  const FlowFiFormSheet({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class FlowFiCard extends StatelessWidget {
  const FlowFiCard({super.key, required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E5DC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B211A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FlowFiEmptyState extends StatelessWidget {
  const FlowFiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: FlowFiCard(
          color: const Color(0xFFFFF6EB),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: const Color(0xFF49672A)),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF757872),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowFiErrorState extends StatelessWidget {
  const FlowFiErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: FlowFiCard(
          color: const Color(0xFFFFF6EB),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: Color(0xFFBA1A1A),
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Check the backend connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF757872),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

SliverList separatedSliverList({
  required int itemCount,
  required Widget Function(BuildContext context, int index) itemBuilder,
}) {
  return SliverList.separated(
    itemCount: itemCount,
    itemBuilder: itemBuilder,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
  );
}
