import '../../../core/network/dio_client.dart';

abstract interface class BudgetRepository {
  Future<List<Map<String, dynamic>>> getBudgets();
  Future<List<Map<String, dynamic>>> getGoals();
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data);
  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> data);
}

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<Map<String, dynamic>>> getBudgets() async {
    final response = await _dioClient.dio.get('/analytics/budgets');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getGoals() async {
    final response = await _dioClient.dio.get('/analytics/goals');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/analytics/goals', data: data);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/analytics/budgets', data: data);
    return response.data as Map<String, dynamic>;
  }
}
