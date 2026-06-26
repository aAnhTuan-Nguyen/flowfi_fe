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
  });

  final String aiRequestId;
  final String aiResultId;
  final String imageUrl;
  final String? imageType;
  final String? confidence;
  final List<String> warnings;
  final List<CreatedImageTransactionModel> createdTransactions;

  factory ImageTransactionImportModel.fromJson(JsonMap json) {
    final analysis = _readMap(json['analysis']);
    return ImageTransactionImportModel(
      aiRequestId: json['aiRequestId']?.toString() ?? '',
      aiResultId: json['aiResultId']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      imageType: analysis['imageType']?.toString(),
      confidence: analysis['confidence']?.toString(),
      warnings: _readStringList(analysis['warnings']),
      createdTransactions: _readList(
        json['createdTransactions'],
      ).map(CreatedImageTransactionModel.fromJson).toList(growable: false),
    );
  }

  ImageTransactionImport toDomain() {
    return ImageTransactionImport(
      aiRequestId: aiRequestId,
      aiResultId: aiResultId,
      imageUrl: imageUrl,
      imageType: imageType,
      confidence: confidence,
      warnings: warnings,
      createdTransactions: createdTransactions
          .map((model) => model.toDomain())
          .toList(growable: false),
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
