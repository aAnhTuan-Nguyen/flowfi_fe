import '../../../core/network/dio_client.dart';

abstract interface class ProfileRepository {
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> data);
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dioClient.dio.get('/users/me');
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.dio.put('/users/me', data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> data,
  ) async {
    final response =
        await _dioClient.dio.put('/users/me/preferences', data: data);
    return response.data['data'] as Map<String, dynamic>;
  }
}
