import 'package:go_router/go_router.dart';

import '../app/app_shell.dart';
import '../features/auth/presentation/screens/auth_gate.dart';
import 'app_routes.dart';

GoRouter createAppRouter({String initialLocation = AppRoutes.root}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AuthGate(
          authenticatedChild: FlowFiAppShell(selectedIndex: 0),
        ),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const AuthGate(
          authenticatedChild: FlowFiAppShell(selectedIndex: 1),
        ),
      ),
      GoRoute(
        path: AppRoutes.wallets,
        builder: (context, state) => const AuthGate(
          authenticatedChild: FlowFiAppShell(selectedIndex: 2),
        ),
      ),
      GoRoute(
        path: AppRoutes.budgets,
        builder: (context, state) => const AuthGate(
          authenticatedChild: FlowFiAppShell(selectedIndex: 3),
        ),
      ),
      GoRoute(
        path: AppRoutes.insights,
        builder: (context, state) => const AuthGate(
          authenticatedChild: FlowFiAppShell(selectedIndex: 4),
        ),
      ),
    ],
  );
}
