import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/ai_image_file.dart';
import '../models/image_transaction_import_model.dart';

abstract interface class AiProcessingRemoteDataSource {
  Future<ImageTransactionImportModel> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  });
}

final class DioAiProcessingRemoteDataSource
    implements AiProcessingRemoteDataSource {
  DioAiProcessingRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ImageTransactionImportModel> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  }) async {
    final response = await _dio.post<Object?>(
      'ai-processing/images/transactions',
      data: FormData.fromMap({
        'WalletId': walletId,
        'Image': MultipartFile.fromBytes(
          image.bytes,
          filename: image.name,
          contentType: DioMediaType.parse(image.mimeType),
        ),
      }),
    );
    return ImageTransactionImportModel.fromJson(readApiObject(response.data));
  }
}
