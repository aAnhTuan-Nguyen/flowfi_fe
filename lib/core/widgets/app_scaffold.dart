import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';
import 'bottom_navigation.dart';

/// Main scaffold for all shell-route screens
/// Provides bottom navigation and FAB-triggered add transaction
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.wallet)) return 1;
    if (location.startsWith(AppRoutes.analytics)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex(context),
        onAddPressed: () => context.push(AppRoutes.addTransaction),
      ),
    );
  }
}
