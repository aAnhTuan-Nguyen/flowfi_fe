import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/ai_processing/data/datasources/ai_processing_remote_data_source.dart';
import 'package:flowfi_fe/features/ai_processing/domain/entities/ai_image_file.dart';
import 'package:flowfi_fe/features/transactions/data/datasources/transaction_remote_data_source.dart';
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

  test(
    'patches only backend-editable fields when updating a transaction',
    () async {
      final adapter = CapturingAdapter(
        responseBody: {
          'success': true,
          'data': {
            'id': 'transaction-1',
            'walletId': 'wallet-1',
            'tagId': 'tag-2',
            'title': 'Coffee',
            'description': 'Morning coffee',
            'amount': '50000',
            'transactionType': 'Expense',
            'transactionDate': '2026-06-27T08:00:00.000Z',
            'inputMethod': 'OCR',
            'status': 'Draft',
            'merchantName': 'Cafe',
          },
        },
      );
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1/'))
        ..httpClientAdapter = adapter;
      final dataSource = DioTransactionRemoteDataSource(dio);

      await dataSource.updateTransaction(
        'transaction-1',
        tagId: 'tag-2',
        title: 'Coffee',
        amount: '50000',
        type: MoneyFlowType.expense,
        date: DateTime.utc(2026, 6, 27, 8),
        merchantName: 'Cafe',
        description: 'Morning coffee',
      );

      expect(adapter.options.path, 'transactions/transaction-1');
      expect(adapter.options.method, 'PATCH');
      expect(adapter.options.data, isA<Map<String, Object?>>());
      final body = adapter.options.data as Map<String, Object?>;
      expect(body, {
        'tagId': 'tag-2',
        'title': 'Coffee',
        'description': 'Morning coffee',
        'amount': '50000',
        'transactionType': 'Expense',
        'transactionDate': '2026-06-27T08:00:00.000Z',
        'merchantName': 'Cafe',
      });
      expect(body, isNot(contains('walletId')));
      expect(body, isNot(contains('status')));
      expect(body, isNot(contains('inputMethod')));
      expect(body, isNot(contains('clientId')));
    },
  );
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
