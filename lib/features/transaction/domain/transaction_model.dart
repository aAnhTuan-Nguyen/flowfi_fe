import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.tagId,
    required this.amount,
    required this.type, // "INCOME" hoặc "EXPENSE"
    required this.transactionDate,
    this.title,
    this.note,
    this.source,
    this.syncStatus,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String walletId;
  final String tagId; // tương ứng TagId từ BE
  final double amount;
  final String type; // "INCOME" | "EXPENSE"
  final DateTime transactionDate;
  final String? title;
  final String? note;
  final String? source;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Tiện ích: kiểm tra có phải chi tiêu không
  bool get isExpense => type == 'EXPENSE';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      walletId: json['walletId']?.toString() ?? '',
      tagId: json['tagId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'EXPENSE',
      title: json['title'] as String?,
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      note: json['note'] as String?,
      source: json['source'] as String?,
      syncStatus: json['syncStatus'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'walletId': walletId,
      'tagId': tagId,
      'amount': amount,
      'type': type,
      if (title != null) 'title': title,
      'transactionDate': transactionDate.toIso8601String(),
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (syncStatus != null) 'syncStatus': syncStatus,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        walletId,
        tagId,
        amount,
        type,
        transactionDate,
        title,
        note,
        source,
        syncStatus,
        createdAt,
        updatedAt,
      ];
}
