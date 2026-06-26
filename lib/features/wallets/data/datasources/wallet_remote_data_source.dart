import 'package:dio/dio.dart';

import '../../../../core/network/api_list_parser.dart';
import '../models/wallet_model.dart';

abstract interface class WalletRemoteDataSource {
  Future<List<WalletModel>> listWallets({int page = 1, int limit = 20});

  Future<WalletModel> getWallet(String id);

  Future<WalletModel> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  });

  Future<WalletModel> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  });

  Future<void> deleteWallet(String id);

  Future<WalletModel> setDefaultWallet(String id);
}

final class DioWalletRemoteDataSource implements WalletRemoteDataSource {
  DioWalletRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<WalletModel>> listWallets({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Object?>(
      'wallets',
      queryParameters: {'page': page, 'limit': limit},
    );
    return readApiList(response.data).map(WalletModel.fromJson).toList();
  }

  @override
  Future<WalletModel> getWallet(String id) async {
    final response = await _dio.get<Object?>('wallets/$id');
    return WalletModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<WalletModel> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  }) async {
    final data = <String, Object?>{
      'name': name,
      'walletType': type.apiValue,
      'balance': balance,
      'clientId': clientId,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.post<Object?>('wallets', data: data);
    return WalletModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<WalletModel> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  }) async {
    final data = <String, Object?>{
      'name': name,
      'walletType': type?.apiValue,
      'balance': balance,
      'clientId': clientId,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.patch<Object?>('wallets/$id', data: data);
    return WalletModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<void> deleteWallet(String id) async {
    await _dio.delete<void>('wallets/$id');
  }

  @override
  Future<WalletModel> setDefaultWallet(String id) async {
    final response = await _dio.post<Object?>('wallets/$id/default');
    return WalletModel.fromJson(readApiObject(response.data));
  }
}
