import 'package:dio/dio.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../core/network/api_list_parser.dart';
import '../models/tag_model.dart';

abstract interface class TagRemoteDataSource {
  Future<List<TagModel>> listTags({int page = 1, int limit = 50});

  Future<TagModel> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  });

  Future<TagModel> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  });

  Future<void> deleteTag(String id);
}

final class DioTagRemoteDataSource implements TagRemoteDataSource {
  DioTagRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<TagModel>> listTags({int page = 1, int limit = 50}) async {
    final response = await _dio.get<Object?>(
      'tags',
      queryParameters: {'page': page, 'limit': limit},
    );
    return readApiList(response.data).map(TagModel.fromJson).toList();
  }

  @override
  Future<TagModel> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  }) async {
    final data = <String, Object?>{
      'name': name,
      'type': type.apiValue,
      'clientId': clientId,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.post<Object?>('tags', data: data);
    return TagModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<TagModel> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  }) async {
    final data = <String, Object?>{
      'name': name,
      'type': type?.apiValue,
      'clientId': clientId,
    }..removeWhere((_, value) => value == null);
    final response = await _dio.patch<Object?>('tags/$id', data: data);
    return TagModel.fromJson(readApiObject(response.data));
  }

  @override
  Future<void> deleteTag(String id) async {
    await _dio.delete<void>('tags/$id');
  }
}
