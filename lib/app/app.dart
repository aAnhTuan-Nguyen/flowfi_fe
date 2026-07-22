import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'app_theme_controller.dart';
import 'app_theme.dart';

class FlowFiApp extends ConsumerWidget {
  const FlowFiApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'FlowFi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      routerConfig: router,
      builder: (context, child) {
        final foruiTheme = buildForuiTheme(Theme.of(context).brightness);

        return FTheme(
          data: foruiTheme,
          child: FToaster(
            child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
