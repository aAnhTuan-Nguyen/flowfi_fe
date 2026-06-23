import '../../../core/network/dio_client.dart';

abstract interface class WalletRepository {
  Future<List<Map<String, dynamic>>> getWallets();
  Future<Map<String, dynamic>> createWallet(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateWallet(
    String walletId,
    Map<String, dynamic> data,
  );
  Future<void> deleteWallet(String walletId);
  Future<void> transfer({
    required String userId,
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? note,
  });
}

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<Map<String, dynamic>>> getWallets() async {
    final response = await _dioClient.dio.get('/finance/api/wallets');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createWallet(
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.dio.post('/finance/api/wallets', data: data);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateWallet(
    String walletId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.dio.put(
      '/finance/api/wallets/$walletId',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    await _dioClient.dio.delete('/finance/api/wallets/$walletId');
  }

  @override
  Future<void> transfer({
    required String userId,
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? note,
  }) async {
    // BE route: POST /finance/api/internal-transfers
    // Body fields: UserId, FromWalletId, ToWalletId, Amount, Note (optional)
    await _dioClient.dio.post(
      '/finance/api/internal-transfers',
      data: {
        'userId': userId,
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'amount': amount,
        if (note != null) 'note': note,
      },
    );
  }
}
