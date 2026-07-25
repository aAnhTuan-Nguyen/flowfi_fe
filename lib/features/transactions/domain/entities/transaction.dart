import '../../../../core/finance/money_flow_type.dart';
import '../../../../core/finance/decimal_money.dart';

enum TransactionStatus { draft, confirmed, unknown }

enum TransactionInputMethod { manual, voice, ocr, unknown }

extension TransactionStatusApi on TransactionStatus {
  String get apiValue {
    return switch (this) {
      TransactionStatus.draft => 'Draft',
      TransactionStatus.confirmed => 'Confirmed',
      TransactionStatus.unknown => 'Unknown',
    };
  }
}

extension TransactionInputMethodApi on TransactionInputMethod {
  String get apiValue {
    return switch (this) {
      TransactionInputMethod.manual => 'Manual',
      TransactionInputMethod.voice => 'Voice',
      TransactionInputMethod.ocr => 'OCR',
      TransactionInputMethod.unknown => 'Unknown',
    };
  }
}

final class Transaction {
  const Transaction({
    required this.id,
    this.clientId,
    this.walletId,
    this.tagId,
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.status,
    required this.inputMethod,
    this.merchantName,
    this.updatedAt,
    this.isPendingSync = false,
  });

  final String id;
  final String? clientId;
  final String? walletId;
  final String? tagId;
  final String title;
  final String? description;
  final String amount;
  final MoneyFlowType type;
  final DateTime? date;
  final TransactionStatus status;
  final TransactionInputMethod inputMethod;
  final String? merchantName;
  final DateTime? updatedAt;
  final bool isPendingSync;

  DateTime? get activityAt => updatedAt ?? date;
}

final class TransactionSummary {
  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
  });

  final String totalIncome;
  final String totalExpense;
}

TransactionSummary summarizeTransactions(
  Iterable<Transaction> transactions, {
  required DateTime from,
  required DateTime to,
}) {
  var income = BigInt.zero;
  var expense = BigInt.zero;
  for (final transaction in transactions) {
    final date = transaction.date;
    if (date == null ||
        date.isBefore(from) ||
        date.isAfter(to) ||
        transaction.status != TransactionStatus.confirmed) {
      continue;
    }
    final amount = parseMoneyMinorUnits(transaction.amount);
    switch (transaction.type) {
      case MoneyFlowType.income:
        income += amount;
      case MoneyFlowType.expense:
        expense += amount;
      case MoneyFlowType.unknown:
        break;
    }
  }
  return TransactionSummary(
    totalIncome: formatMoneyMinorUnits(income),
    totalExpense: formatMoneyMinorUnits(expense),
  );
}

int compareTransactionActivityDescending(Transaction left, Transaction right) {
  final leftActivity =
      left.activityAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  final rightActivity =
      right.activityAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  final activityComparison = rightActivity.compareTo(leftActivity);
  if (activityComparison != 0) {
    return activityComparison;
  }
  return right.id.compareTo(left.id);
}

List<Transaction> sortTransactionsByActivity(
  Iterable<Transaction> transactions,
) {
  return transactions.toList(growable: false)
    ..sort(compareTransactionActivityDescending);
}

TransactionStatus transactionStatusFromApi(Object? value) {
  return switch (value) {
    'Draft' => TransactionStatus.draft,
    'Confirmed' => TransactionStatus.confirmed,
    _ => TransactionStatus.unknown,
  };
}

TransactionInputMethod transactionInputMethodFromApi(Object? value) {
  return switch (value) {
    'Manual' => TransactionInputMethod.manual,
    'Voice' => TransactionInputMethod.voice,
    'OCR' => TransactionInputMethod.ocr,
    _ => TransactionInputMethod.unknown,
  };
}
