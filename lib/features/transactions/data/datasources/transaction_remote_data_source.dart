import 'package:dio/dio.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';

abstract interface class TransactionRemoteDataSource {
  Future<List<TransactionModel>> listTransactions({
    int page = 1,
    int limit = 20,
    String? walletId,
    String? tagId,
    MoneyFlowType? transactionType,
    TransactionStatus? status,
    TransactionInputMethod? inputMethod,
    String? keyword,
    String? from,
    String? to,
  });

  Future<TransactionModel> createTransaction({
    required String walletId,
    required String tagId,
    required String title,
    required String amount,
    required MoneyFlowType type,
    required DateTime date,
    TransactionStatus status = TransactionStatus.draft,
    TransactionInputMethod inputMethod = TransactionInputMethod.manual,
    String? merchantName,
    String? description,
    String? clientId,
  });

  Future<TransactionModel> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  });

  Future<void> deleteTransaction(String id);

  Future<TransactionModel> confirmTransaction(String id);
}

final class DioTransactionRemoteDataSource
    implements TransactionRemoteDataSource {
  DioTransactionRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<TransactionModel>> listTransactions({
    int page = 1,
    int limit = 20,
    String? walletId,
    String? tagId,
    MoneyFlowType? transactionType,
    TransactionStatus? status,
    TransactionInputMethod? inputMethod,
    String? keyword,
    String? from,
    String? to,
  }) async {
    final queryParameters = <String, Object?>{
      'page': page,
      'limit': limit,
      'walletId': walletId,
      'tagId': tagId,
      'transactionType':
          transactionType != null && transactionType != MoneyFlowType.unknown
          ? transactionType.apiValue
          : null,
      'status': status != null && status != TransactionStatus.unknown
          ? status.apiValue
          : null,
      'inputMethod':
          inputMethod != null && inputMethod != TransactionInputMethod.unknown
          ? inputMethod.apiValue
          : null,
      'keyword': keyword != null && keyword.isNotEmpty ? keyword : null,
      'from': from,
      'to': to,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.get<Object?>(
      'transactions',
      queryParameters: queryParameters,
    );
    return readApiList(response.data).map(TransactionModel.fromJson).toList();
  }

  @override
  Future<TransactionModel> createTransaction({
    required String walletId,
    required String tagId,
    required String title,
    required String amount,
    required MoneyFlowType type,
    required DateTime date,
    TransactionStatus status = TransactionStatus.draft,
    TransactionInputMethod inputMethod = TransactionInputMethod.manual,
    String? merchantName,
    String? description,
    String? clientId,
  }) async {
    final data = <String, Object?>{
      'walletId': walletId,
      'tagId': tagId,
      'title': title,
      'description': description,
      'amount': amount,
      'transactionType': type.apiValue,
      'transactionDate': date.toIso8601String(),
      'inputMethod': inputMethod.apiValue,
      'status': status.apiValue,
      'merchantName': merchantName,
      'clientId': clientId,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.post<Object?>('transactions', data: data);
    return TransactionModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<TransactionModel> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) async {
    final data = <String, Object?>{
      'tagId': tagId,
      'title': title,
      'description': description,
      'amount': amount,
      'transactionType': type?.apiValue,
      'transactionDate': date?.toIso8601String(),
      'merchantName': merchantName,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.patch<Object?>('transactions/$id', data: data);
    return TransactionModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _dio.delete<void>('transactions/$id');
  }

  @override
  Future<TransactionModel> confirmTransaction(String id) async {
    final response = await _dio.patch<Object?>('transactions/$id/confirm');
    return TransactionModel.fromJson(readApiObject(response.data));
  }
}
