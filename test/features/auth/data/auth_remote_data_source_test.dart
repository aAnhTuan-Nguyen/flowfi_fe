import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowfi_fe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('patches editable profile fields to users/me', () async {
    final adapter = _CapturingAdapter(
      responseBody: {
        'success': true,
        'data': {
          'id': 'user-1',
          'email': 'alex@example.com',
          'fullName': 'Alex Nguyen',
          'currencyCode': 'VND',
          'monthlyBudgetLimit': '5000000',
        },
      },
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1/'))
      ..httpClientAdapter = adapter;
    final dataSource = DioAuthRemoteDataSource(dio);

    final user = await dataSource.updateProfile(
      fullName: 'Alex Nguyen',
      currencyCode: 'VND',
      monthlyBudgetLimit: '5000000',
    );

    expect(adapter.options.path, 'users/me');
    expect(adapter.options.method, 'PATCH');
    expect(adapter.options.data, {
      'fullName': 'Alex Nguyen',
      'currencyCode': 'VND',
      'monthlyBudgetLimit': '5000000',
    });
    expect(user.fullName, 'Alex Nguyen');
    expect(user.currencyCode, 'VND');
    expect(user.monthlyBudgetLimit, '5000000');
  });
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
