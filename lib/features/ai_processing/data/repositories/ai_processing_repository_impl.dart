import '../../domain/entities/ai_image_file.dart';
import '../../domain/entities/image_transaction_import.dart';
import '../../domain/repositories/ai_processing_repository.dart';
import '../datasources/ai_processing_remote_data_source.dart';

final class AiProcessingRepositoryImpl implements AiProcessingRepository {
  const AiProcessingRepositoryImpl(this._remoteDataSource);

  final AiProcessingRemoteDataSource _remoteDataSource;

  @override
  Future<ImageTransactionImport> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  }) async {
    final model = await _remoteDataSource.createTransactionsFromImage(
      walletId: walletId,
      image: image,
    );
    return model.toDomain();
  }
}
