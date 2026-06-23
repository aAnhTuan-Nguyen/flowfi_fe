import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/wallet/presentation/wallet_screen.dart';
import '../features/wallet/presentation/internal_transfer_screen.dart';
import '../features/transaction/presentation/transaction_history_screen.dart';
import '../features/transaction/presentation/add_transaction_screen.dart';
import '../features/transaction/presentation/ai_review_screen.dart';
import '../features/transaction/presentation/create_tag_screen.dart';
import '../features/wallet/presentation/create_wallet_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/budget/presentation/budget_screen.dart';
import '../features/budget/presentation/create_budget_screen.dart';
import '../features/notification/presentation/notification_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/preferences_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../core/widgets/app_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // ─── Auth routes (no shell) ──────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ─── Main shell (bottom nav) ─────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.wallet,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: WalletScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ─── Push routes (full-screen, no shell) ─────────────────
      GoRoute(
        path: AppRoutes.transactions,
        builder: (_, __) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (_, __) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiReview,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final imagePath = extra?['imagePath'] as String?;
          return AiReviewScreen(imagePath: imagePath ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.createTag,
        builder: (_, __) => const CreateTagScreen(),
      ),
      GoRoute(
        path: AppRoutes.transfer,
        builder: (_, __) => const InternalTransferScreen(),
      ),
      GoRoute(
        path: AppRoutes.createWallet,
        builder: (_, __) => const CreateWalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.budget,
        builder: (_, __) => const BudgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.createBudget,
        builder: (_, __) => const CreateBudgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.preferences,
        builder: (_, __) => const PreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
    ],
  );
}

/// Route path constants for type-safe navigation
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Tabs
  static const String home = '/home';
  static const String wallet = '/wallet';
  static const String transfer = '/wallet/transfer';
  static const String createWallet = '/wallet/create';
  static const String transactions = '/transactions';
  static const String addTransaction = '/transactions/add';
  static const String aiReview = '/transactions/ai-review';
  static const String createTag = '/transactions/create-tag';
  static const String analytics = '/analytics';
  static const String budget = '/budget';
  static const String createBudget = '/budget/create';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String preferences = '/profile/preferences';
  static const String changePassword = '/profile/change-password';
}
