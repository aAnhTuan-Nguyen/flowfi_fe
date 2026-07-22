import '../../../transactions/domain/entities/transaction.dart';

final class ImageTransactionImport {
  const ImageTransactionImport({
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
  final List<CreatedImageTransaction> createdTransactions;
  final List<ReceiptDetail> receiptDetails;
}

final class ReceiptDetail {
  const ReceiptDetail({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final num quantity;
  final double price;
}

final class CreatedImageTransaction {
  const CreatedImageTransaction({
    required this.transaction,
    required this.tagCreated,
  });

  final Transaction transaction;
  final bool tagCreated;
}
