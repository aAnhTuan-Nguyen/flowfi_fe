import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/constants/app_constants.dart';
import '../routes/app_router.dart';

class FlowFiApp extends ConsumerWidget {
  const FlowFiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(false, themeState.seedColor),
      darkTheme: AppTheme.getTheme(true, themeState.seedColor),
      themeMode: themeState.themeMode,
      routerConfig: router,
    );
  }
}
