import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowfi_fe/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loads confirmed transaction totals from the summary endpoint',
    () async {
      final adapter = _CapturingAdapter(
        responseBody: {
          'success': true,
          'data': {
            'totalIncome': '11511111.00',
            'totalExpense': '143304567.00',
          },
        },
      );
      final dataSource = _dataSource(adapter);

      final summary = await dataSource.getSummary(
        from: '2026-07-01T00:00:00.000',
        to: '2026-07-31T23:59:59.999',
      );

      expect(adapter.options.method, 'GET');
      expect(adapter.options.path, 'transactions/summary');
      expect(adapter.options.queryParameters, {
        'from': '2026-07-01T00:00:00.000',
        'to': '2026-07-31T23:59:59.999',
      });
      expect(summary.totalIncome, '11511111.00');
      expect(summary.totalExpense, '143304567.00');
    },
  );

  test('confirms a transaction with the backend PATCH contract', () async {
    final adapter = _CapturingAdapter(
      responseBody: {
        'success': true,
        'data': {
          'id': 'transaction-1',
          'title': 'Coffee',
          'amount': '50000',
          'transactionType': 'Expense',
          'transactionDate': '2026-07-25T00:00:00.000Z',
          'status': 'Confirmed',
          'inputMethod': 'OCR',
        },
      },
    );
    final dataSource = _dataSource(adapter);

    await dataSource.confirmTransaction('transaction-1');

    expect(adapter.options.method, 'PATCH');
    expect(adapter.options.path, 'transactions/transaction-1/confirm');
  });
}

DioTransactionRemoteDataSource _dataSource(_CapturingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1/'))
    ..httpClientAdapter = adapter;
  return DioTransactionRemoteDataSource(dio);
}

final class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter({required this.responseBody});

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
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
