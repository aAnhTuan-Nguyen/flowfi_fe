import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/budgets/data/models/budget_model.dart';
import 'package:flowfi_fe/features/goals/data/models/goal_model.dart';
import 'package:flowfi_fe/features/transactions/data/models/transaction_model.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transaction model parses relation ids from top-level fields', () {
    final model = TransactionModel.fromJson({
      'id': 'transaction-1',
      'walletId': 'wallet-1',
      'tagId': 'tag-1',
      'title': 'Lunch',
      'amount': '12.50',
      'transactionType': 'Expense',
      'transactionDate': '2026-01-02T00:00:00.000',
      'status': 'Draft',
      'inputMethod': 'Manual',
    });

    expect(model.walletId, 'wallet-1');
    expect(model.tagId, 'tag-1');
    expect(model.type, MoneyFlowType.expense);
    expect(model.status, TransactionStatus.draft);
  });

  test('transaction model parses relation ids from nested objects', () {
    final transaction = TransactionModel.fromJson({
      'id': 'transaction-1',
      'wallet': {'id': 'wallet-2', 'name': 'Cash'},
      'tag': {'id': 'tag-2', 'name': 'Food'},
      'title': 'Lunch',
      'amount': '12.50',
      'transactionType': 'Expense',
      'transactionDate': '2026-01-02T00:00:00.000',
      'status': 'Confirmed',
      'inputMethod': 'Manual',
    }).toDomain();

    expect(transaction.walletId, 'wallet-2');
    expect(transaction.tagId, 'tag-2');
  });

  test('budget model parses tag id from top-level and nested fields', () {
    final topLevel = BudgetModel.fromJson({
      'id': 'budget-1',
      'tagId': 'tag-1',
      'budgetAmount': '500',
      'month': 1,
      'year': 2026,
      'warningThresholdPercent': 80,
    }).toDomain();
    final nested = BudgetModel.fromJson({
      'id': 'budget-2',
      'tag': {'id': 'tag-2', 'name': 'Food'},
      'budgetAmount': '600',
      'month': 2,
      'year': 2026,
      'warningThresholdPercent': 75,
    }).toDomain();

    expect(topLevel.tagId, 'tag-1');
    expect(nested.tagId, 'tag-2');
  });

  test('goal model parses wallet id from top-level and nested fields', () {
    final topLevel = GoalModel.fromJson({
      'id': 'goal-1',
      'walletId': 'wallet-1',
      'name': 'Emergency fund',
      'targetAmount': '1000',
      'currentAmount': '100',
      'status': 'Active',
    }).toDomain();
    final nested = GoalModel.fromJson({
      'id': 'goal-2',
      'wallet': {'id': 'wallet-2', 'name': 'Cash'},
      'name': 'Travel',
      'targetAmount': '2000',
      'currentAmount': '250',
      'status': 'Active',
    }).toDomain();

    expect(topLevel.walletId, 'wallet-1');
    expect(nested.walletId, 'wallet-2');
  });
}
