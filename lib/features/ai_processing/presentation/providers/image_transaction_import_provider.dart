import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/ai_image_file.dart';
import '../../domain/entities/image_transaction_import.dart';
import '../../domain/repositories/ai_processing_repository.dart';

const allowedAiImageMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};
const maxAiImageBytes = 5 * 1024 * 1024;

final aiProcessingRepositoryProvider = Provider<AiProcessingRepository>(
  (ref) => serviceLocator<AiProcessingRepository>(),
);

class ImageTransactionImportNotifier
    extends AsyncNotifier<ImageTransactionImport?> {
  @override
  Future<ImageTransactionImport?> build() async {
    return null;
  }

  Future<ImageTransactionImport> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  }) async {
    validateAiImageFile(image);
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(aiProcessingRepositoryProvider)
          .createTransactionsFromImage(walletId: walletId, image: image);
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final imageTransactionImportProvider =
    AsyncNotifierProvider<
      ImageTransactionImportNotifier,
      ImageTransactionImport?
    >(ImageTransactionImportNotifier.new);

void validateAiImageFile(AiImageFile image) {
  final mimeType = image.mimeType.trim().toLowerCase();
  if (!allowedAiImageMimeTypes.contains(mimeType)) {
    throw const AiImageValidationException(
      'Use a JPG, PNG, or WebP receipt image.',
    );
  }
  if (image.sizeBytes <= 0) {
    throw const AiImageValidationException('Choose a non-empty receipt image.');
  }
  if (image.sizeBytes > maxAiImageBytes) {
    throw const AiImageValidationException(
      'Receipt image must be 5 MB or smaller.',
    );
  }
}

final class AiImageValidationException implements Exception {
  const AiImageValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
