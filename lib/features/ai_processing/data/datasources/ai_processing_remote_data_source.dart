import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/ai_image_file.dart';
import '../../domain/entities/voice_transaction_import.dart';
import '../models/image_transaction_import_model.dart';
import '../models/voice_transaction_import_model.dart';

abstract interface class AiProcessingRemoteDataSource {
  Future<ImageTransactionImportModel> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  });

  Future<VoiceTransactionImportModel> createTransactionFromVoice({
    required String walletId,
    required AiVoiceFile voice,
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

  @override
  Future<VoiceTransactionImportModel> createTransactionFromVoice({
    required String walletId,
    required AiVoiceFile voice,
  }) async {
    final response = await _dio.post<Object?>(
      'ai-processing/voices/transactions',
      data: FormData.fromMap({
        'WalletId': walletId,
        'Voice': MultipartFile.fromBytes(
          voice.bytes,
          filename: voice.name,
          contentType: DioMediaType.parse(voice.mimeType),
        ),
      }),
    );
    return VoiceTransactionImportModel.fromJson(readApiObject(response.data));
  }
}
