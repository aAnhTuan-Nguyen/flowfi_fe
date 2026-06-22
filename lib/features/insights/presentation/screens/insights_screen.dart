import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/placeholder_tab_screen.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTabScreen(
      icon: Icons.insights_rounded,
      title: 'Insights',
      message: 'AI insights and reports will live here.',
    );
  }
}
