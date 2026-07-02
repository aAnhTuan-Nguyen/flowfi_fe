import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'app_theme.dart';

class FlowFiApp extends StatelessWidget {
  const FlowFiApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final foruiTheme = buildForuiTheme();

    return MaterialApp.router(
      title: 'FlowFi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      routerConfig: router,
      builder: (context, child) {
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
