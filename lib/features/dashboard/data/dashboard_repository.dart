import '../../../core/network/dio_client.dart';

abstract interface class DashboardRepository {
  Future<Map<String, dynamic>> getSummary();
  Future<List<double>> getWeeklySpending();
}

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dioClient);

  // ignore: unused_field
  final DioClient _dioClient;

  @override
  Future<Map<String, dynamic>> getSummary() async {
    // Missing backend endpoint
    return {
      'balance': 0.0,
      'income': 0.0,
      'expense': 0.0,
    };
  }

  @override
  Future<List<double>> getWeeklySpending() async {
    // Missing backend endpoint
    return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  }
}
