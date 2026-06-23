import '../../../core/network/dio_client.dart';

abstract interface class AnalyticsRepository {
  Future<Map<String, dynamic>> getSummary({
    required String period, // day|week|month|year
  });
  Future<List<Map<String, dynamic>>> getCategoryBreakdown({
    required String period,
  });
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Map<String, dynamic>> getSummary({
    required String period,
  }) async {
    final response = await _dioClient.dio.get(
      '/analytics/summary',
      queryParameters: {'period': period},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryBreakdown({
    required String period,
  }) async {
    final response = await _dioClient.dio.get(
      '/analytics/categories',
      queryParameters: {'period': period},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
