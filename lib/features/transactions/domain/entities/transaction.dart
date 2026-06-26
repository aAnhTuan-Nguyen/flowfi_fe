import '../../../../core/finance/money_flow_type.dart';

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
  });

  final String id;
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
