import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';

abstract interface class AuthRepository {
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  });
  Future<void> loginWithGoogle();
  Future<void> logout();
  Future<void> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String userId});
  Future<void> forgotPassword(String email);
  Future<bool> hasActiveSession();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dioClient, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final DioClient _dioClient;
  final FlutterSecureStorage _storage;

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final tokens = data['tokens'];
    if (tokens != null) {
      final accessToken = tokens['accessToken'];
      if (accessToken != null) {
        await _storage.write(
            key: AppConstants.keyAccessToken, value: accessToken);
      }
      final refreshToken = tokens['refreshToken'];
      if (refreshToken != null) {
        await _storage.write(
            key: AppConstants.keyRefreshToken, value: refreshToken);
      }
    }
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    if (response.data != null && response.data['data'] != null) {
      await _saveTokens(response.data['data']);
    }
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      '/auth/register',
      data: {'fullName': fullName, 'email': email, 'password': password},
    );
    if (response.data != null && response.data['data'] != null) {
      await _saveTokens(response.data['data']);
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    // Backend integration: replace with actual Google auth if supported by backend
    await _dioClient.dio.post('/auth/google');
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.dio.post('/auth/logout');
    } finally {
      await _storage.delete(key: AppConstants.keyAccessToken);
      await _storage.delete(key: AppConstants.keyRefreshToken);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String userId,
  }) async {
    await _dioClient.dio.post('/auth/change-password', data: {
      'userId': userId,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.dio.post('/auth/forgot-password', data: {
      'email': email,
    });
  }

  @override
  Future<bool> hasActiveSession() async {
    try {
      final response = await _dioClient.dio.get('/users/me');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
