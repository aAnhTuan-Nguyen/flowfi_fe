import 'dart:convert';
import '../../../../core/network/api_list_parser.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/image_transaction_import.dart';
final class ImageTransactionImportModel {
  const ImageTransactionImportModel({
    required this.aiRequestId,
    required this.aiResultId,
    required this.imageUrl,
    required this.createdTransactions,
    this.imageType,
    this.confidence,
    this.warnings = const [],
    this.receiptDetails = const [],
  });

  final String aiRequestId;
  final String aiResultId;
  final String imageUrl;
  final String? imageType;
  final String? confidence;
  final List<String> warnings;
  final List<CreatedImageTransactionModel> createdTransactions;
  final List<ReceiptDetailModel> receiptDetails;

  factory ImageTransactionImportModel.fromJson(JsonMap json) {
    final analysis = _readMap(json['analysis']);
    final createdTransactions = _readList(
      json['createdTransactions'],
    ).map(CreatedImageTransactionModel.fromJson).toList(growable: false);

    List<ReceiptDetailModel> details = [];
    final rawResponseStr = analysis['rawResponse']?.toString();
    if (rawResponseStr != null && rawResponseStr.isNotEmpty) {
      try {
        final rawJson = jsonDecode(rawResponseStr);
        if (rawJson is Map) {
          var items = rawJson['receiptDetails'] ?? rawJson['receipt_details'];
          if (items == null && rawJson['transactions'] is List && (rawJson['transactions'] as List).isNotEmpty) {
            final tx = (rawJson['transactions'] as List).first;
            if (tx is Map) {
              items = tx['receiptDetails'] ?? tx['receipt_details'];
            }
          }
          if (items is List) {
            details = items.map((e) => ReceiptDetailModel.fromJson(_readMap(e))).toList(growable: false);
          }
        }
      } catch (_) {}
    }

    if (details.isEmpty && createdTransactions.isNotEmpty) {
      final rawText = createdTransactions.first.transaction.description;
      if (rawText != null && rawText.isNotEmpty) {
        details = _parseRawText(rawText);
      }
    }

    return ImageTransactionImportModel(
      aiRequestId: json['aiRequestId']?.toString() ?? '',
      aiResultId: json['aiResultId']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      imageType: analysis['imageType']?.toString(),
      confidence: analysis['confidence']?.toString(),
      warnings: _readStringList(analysis['warnings']),
      createdTransactions: createdTransactions,
      receiptDetails: details,
    );
  }

  static List<ReceiptDetailModel> _parseRawText(String text) {
    final lines = text.split('\n');
    final details = <ReceiptDetailModel>[];
    
    // Regex matching: (optional quantity at start) (item name) (price at end)
    // Example: "2 Banh mi 40.000" or "Cafe 15000"
    final regex = RegExp(r'^(?:(\d+)[xX\*]?\s+)?(.*?)\s+((?:\d{1,3}[.,])*\d{3,})$');
    
    for (final line in lines) {
      final cleanLine = line.trim();
      final lowerLine = cleanLine.toLowerCase();
      // Skip lines that look like totals
      if (lowerLine.contains('tổng') || 
          lowerLine.contains('total') || 
          lowerLine.contains('thành tiền') ||
          lowerLine.contains('tiền mặt')) {
        continue;
      }
      
      final match = regex.firstMatch(cleanLine);
      if (match != null) {
        final qtyStr = match.group(1);
        final name = match.group(2) ?? '';
        final priceStr = match.group(3) ?? '0';
        
        if (name.isNotEmpty && name.length > 2 && !RegExp(r'^\d+$').hasMatch(name)) {
           final qty = int.tryParse(qtyStr ?? '1') ?? 1;
           final price = double.tryParse(priceStr.replaceAll(RegExp(r'[.,]'), '')) ?? 0.0;
           if (price > 0) {
             details.add(ReceiptDetailModel(name: name.trim(), quantity: qty, price: price));
           }
        }
      }
    }
    return details;
  }

  ImageTransactionImport toDomain() {
    return ImageTransactionImport(
      aiRequestId: aiRequestId,
      aiResultId: aiResultId,
      imageUrl: imageUrl,
      imageType: imageType,
      confidence: confidence,
      warnings: warnings,
      receiptDetails: receiptDetails.map((m) => m.toDomain()).toList(growable: false),
      createdTransactions: createdTransactions
          .map((model) => model.toDomain())
          .toList(growable: false),
    );
  }
}

final class ReceiptDetailModel {
  const ReceiptDetailModel({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final num quantity;
  final double price;

  factory ReceiptDetailModel.fromJson(JsonMap json) {
    return ReceiptDetailModel(
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] is num ? json['quantity'] as num : 1,
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
    );
  }

  ReceiptDetail toDomain() {
    return ReceiptDetail(
      name: name,
      quantity: quantity,
      price: price,
    );
  }
}

final class CreatedImageTransactionModel {
  const CreatedImageTransactionModel({
    required this.transaction,
    required this.tagCreated,
  });

  final TransactionModel transaction;
  final bool tagCreated;

  factory CreatedImageTransactionModel.fromJson(JsonMap json) {
    return CreatedImageTransactionModel(
      transaction: TransactionModel.fromJson(_readMap(json['transaction'])),
      tagCreated: json['tagCreated'] == true,
    );
  }

  CreatedImageTransaction toDomain() {
    return CreatedImageTransaction(
      transaction: transaction.toDomain(),
      tagCreated: tagCreated,
    );
  }
}

JsonMap _readMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return JsonMap.from(value);
  }
  return const {};
}

List<JsonMap> _readList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.map(_readMap).toList(growable: false);
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.map((item) => item.toString()).toList(growable: false);
}
