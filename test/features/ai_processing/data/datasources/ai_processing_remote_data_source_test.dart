import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowfi_fe/features/ai_processing/data/datasources/ai_processing_remote_data_source.dart';
import 'package:flowfi_fe/features/ai_processing/domain/entities/ai_image_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('posts receipt image as multipart form data', () async {
    final adapter = CapturingAdapter(
      responseBody: {
        'success': true,
        'data': {
          'aiRequestId': 'request-1',
          'aiResultId': 'result-1',
          'imageUrl': 'local://receipt.jpg',
          'analysis': {'imageType': 'RECEIPT'},
          'createdTransactions': [],
        },
      },
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1/'))
      ..httpClientAdapter = adapter;
    final dataSource = DioAiProcessingRemoteDataSource(dio);

    await dataSource.createTransactionsFromImage(
      walletId: 'wallet-1',
      image: const AiImageFile(
        name: 'receipt.jpg',
        bytes: [1, 2, 3],
        mimeType: 'image/jpeg',
      ),
    );

    expect(adapter.options.path, 'ai-processing/images/transactions');
    expect(adapter.options.method, 'POST');
    expect(adapter.options.data, isA<FormData>());
    final formData = adapter.options.data as FormData;
    expect(formData.fields.single.key, 'WalletId');
    expect(formData.fields.single.value, 'wallet-1');
    expect(formData.files, hasLength(1));
    expect(formData.files.single.key, 'Image');
    expect(formData.files.single.value.filename, 'receipt.jpg');
    expect(formData.files.single.value.contentType.toString(), 'image/jpeg');
  });
}

final class CapturingAdapter implements HttpClientAdapter {
  CapturingAdapter({required this.responseBody});

  final Map<String, Object?> responseBody;
  late RequestOptions options;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    return ResponseBody.fromString(
      jsonEncode(responseBody),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
