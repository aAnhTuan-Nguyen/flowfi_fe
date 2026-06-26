import '../../../../core/finance/money_flow_type.dart';
import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/transaction.dart';

final class TransactionModel {
  const TransactionModel({
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

  factory TransactionModel.fromJson(JsonMap json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      walletId: _readRelationId(json, 'walletId', 'wallet'),
      tagId: _readRelationId(json, 'tagId', 'tag'),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      amount: json['amount']?.toString() ?? '0',
      type: moneyFlowTypeFromApi(json['transactionType']),
      date: DateTime.tryParse(json['transactionDate']?.toString() ?? ''),
      status: transactionStatusFromApi(json['status']),
      inputMethod: transactionInputMethodFromApi(json['inputMethod']),
      merchantName: json['merchantName']?.toString(),
    );
  }

  Transaction toDomain() {
    return Transaction(
      id: id,
      walletId: walletId,
      tagId: tagId,
      title: title,
      description: description,
      amount: amount,
      type: type,
      date: date,
      status: status,
      inputMethod: inputMethod,
      merchantName: merchantName,
    );
  }
}

String? _readRelationId(JsonMap json, String topLevelKey, String nestedKey) {
  final topLevelValue = json[topLevelKey]?.toString();
  if (topLevelValue != null && topLevelValue.isNotEmpty) {
    return topLevelValue;
  }
  final nestedValue = json[nestedKey];
  if (nestedValue is Map<String, Object?>) {
    return nestedValue['id']?.toString();
  }
  if (nestedValue is Map) {
    return nestedValue['id']?.toString();
  }
  return null;
}
