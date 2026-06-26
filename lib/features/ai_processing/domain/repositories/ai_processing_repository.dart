import '../entities/ai_image_file.dart';
import '../entities/image_transaction_import.dart';

abstract interface class AiProcessingRepository {
  Future<ImageTransactionImport> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  });
}
