import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../budgets/presentation/providers/budgets_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../notifications/presentation/providers/notification_preferences_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../sync/sync_status_provider.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

/// Disposes every state holder whose value belongs to the signed-in account.
///
/// These providers are intentionally kept alive while the app shell is mounted.
/// Without resetting them at an account boundary, the next account briefly sees
/// the previous account's in-memory data until a manual refresh is performed.
void invalidateAccountData(Ref ref) {
  ref.invalidate(walletsProvider);
  ref.invalidate(tagsProvider);

  ref.invalidate(transactionsMonthProvider);
  ref.invalidate(transactionsProvider);
  ref.invalidate(monthlyTransactionsProvider);
  ref.invalidate(monthlyTransactionSummaryProvider);
  ref.invalidate(expenseTrendTransactionsProvider);
  ref.invalidate(annualTransactionsProvider);

  ref.invalidate(budgetsProvider);
  ref.invalidate(monthlyBudgetDetailsProvider);
  ref.invalidate(annualBudgetSummaryProvider);
  ref.invalidate(goalsProvider);

  ref.invalidate(notificationsProvider);
  ref.invalidate(notificationPreferencesProvider);
  ref.invalidate(syncStatusProvider);
}
