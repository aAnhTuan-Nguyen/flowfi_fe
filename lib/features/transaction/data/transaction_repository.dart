import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

abstract interface class TransactionRepository {
  Future<List<Map<String, dynamic>>> getTransactions({
    String? walletId,
    String? tagId,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getAiReview(String imagePath);
}

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<Map<String, dynamic>>> getTransactions({
    String? walletId,
    String? tagId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Missing endpoint in backend. Return empty list to prevent crash.
    return [];
  }

  @override
  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> data,
  ) async {
    final walletId = data['walletId'];
    final response = await _dioClient.dio.post(
      '/finance/api/wallets/$walletId/transactions',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getAiReview(String imagePath) async {
    MultipartFile file;
    if (kIsWeb) {
      final response = await Dio().get<List<int>>(
        imagePath,
        options: Options(responseType: ResponseType.bytes),
      );
      file = MultipartFile.fromBytes(response.data!, filename: 'receipt.jpg');
    } else {
      file = await MultipartFile.fromFile(imagePath, filename: 'receipt.jpg');
    }

    final formData = FormData.fromMap({
      'file': file,
    });

    final response = await _dioClient.dio.post(
      '/ai/api/ai-processing/images/transactions',
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tag Repository
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class TagRepository {
  Future<List<Map<String, dynamic>>> getTags();
  Future<Map<String, dynamic>> createTag(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateTag(
    String tagId,
    Map<String, dynamic> data,
  );
  Future<void> deleteTag(String tagId);
}

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    final response = await _dioClient.dio.get('/finance/api/tags');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createTag(Map<String, dynamic> data) async {
    // Body BE mong đợi (CreateTagDto):
    // { "userId": "guid", "name": "string", ... }
    final response = await _dioClient.dio.post('/finance/api/tags', data: data);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateTag(
    String tagId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.dio.put(
      '/finance/api/tags/$tagId',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteTag(String tagId) async {
    await _dioClient.dio.delete('/finance/api/tags/$tagId');
  }
}
