import 'package:go_router/go_router.dart';

import '../app/app_shell.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const FlowFiAppShell()),
    ],
  );
}
