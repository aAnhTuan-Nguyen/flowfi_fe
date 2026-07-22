import '../../../../core/network/api_list_parser.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/voice_transaction_import.dart';

final class VoiceTransactionImportModel {
  const VoiceTransactionImportModel({
    required this.aiRequestId,
    required this.aiResultId,
    required this.transcript,
    required this.transaction,
    required this.requiresConfirmation,
  });

  final String aiRequestId;
  final String aiResultId;
  final String transcript;
  final TransactionModel transaction;
  final bool requiresConfirmation;

  factory VoiceTransactionImportModel.fromJson(JsonMap json) {
    return VoiceTransactionImportModel(
      aiRequestId: json['aiRequestId']?.toString() ?? '',
      aiResultId: json['aiResultId']?.toString() ?? '',
      transcript: json['rawText']?.toString() ?? '',
      transaction: TransactionModel.fromJson(_map(json['transaction'])),
      requiresConfirmation: json['requiresConfirmation'] == true,
    );
  }

  VoiceTransactionImport toDomain() => VoiceTransactionImport(
    aiRequestId: aiRequestId,
    aiResultId: aiResultId,
    transcript: transcript,
    transaction: transaction.toDomain(),
    requiresConfirmation: requiresConfirmation,
  );
}

JsonMap _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return JsonMap.from(value);
  return const {};
}
