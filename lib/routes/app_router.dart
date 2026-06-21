import 'package:go_router/go_router.dart';

import '../features/example/presentation/screens/example_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const ExampleScreen()),
    ],
  );
}
