import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/voice_transaction_import.dart';
import 'image_transaction_import_provider.dart';

class VoiceTransactionImportNotifier
    extends AsyncNotifier<VoiceTransactionImport?> {
  @override
  Future<VoiceTransactionImport?> build() async => null;

  Future<VoiceTransactionImport> submit({
    required String walletId,
    required AiVoiceFile voice,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(aiProcessingRepositoryProvider)
          .createTransactionFromVoice(walletId: walletId, voice: voice);
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void clear() => state = const AsyncData(null);
}

final voiceTransactionImportProvider = AsyncNotifierProvider.autoDispose<
  VoiceTransactionImportNotifier,
  VoiceTransactionImport?
>(VoiceTransactionImportNotifier.new);
