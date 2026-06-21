import 'package:dio/dio.dart';
import 'package:flowfi_fe/core/network/dio_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates a Dio client without inventing a backend base URL', () {
    final client = createDioClient();

    expect(client, isA<Dio>());
    expect(client.options.baseUrl, isEmpty);
  });
}
