import '../../../transactions/domain/entities/transaction.dart';

final class AiVoiceFile {
  const AiVoiceFile({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });

  final String name;
  final String mimeType;
  final List<int> bytes;
}

final class VoiceTransactionImport {
  const VoiceTransactionImport({
    required this.aiRequestId,
    required this.aiResultId,
    required this.transcript,
    required this.transaction,
    required this.requiresConfirmation,
  });

  final String aiRequestId;
  final String aiResultId;
  final String transcript;
  final Transaction transaction;
  final bool requiresConfirmation;
}
