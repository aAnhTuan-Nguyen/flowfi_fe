import 'package:dio/dio.dart';

import '../../../../core/sync/pending_sync_operation.dart';

export '../../../../core/sync/pending_sync_operation.dart';

abstract interface class SyncRemoteDataSource {
  Future<SyncPushResponse> push({
    required String deviceId,
    required List<PendingSyncOperation> items,
  });
}

final class DioSyncRemoteDataSource implements SyncRemoteDataSource {
  const DioSyncRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<SyncPushResponse> push({
    required String deviceId,
    required List<PendingSyncOperation> items,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      'sync/push',
      data: {
        'deviceId': deviceId,
        'items': [
          for (final item in items)
            {
              'entityName': item.entityName,
              'entityId': item.entityId,
              'clientId': item.clientId,
              'action': item.action.apiValue,
              'payload': item.payload,
            }..removeWhere((_, value) => value == null),
        ],
      },
    );
    final data = _unwrapData(response.data ?? {});
    final results = data['results'];
    return SyncPushResponse(
      results: results is List
          ? results
                .whereType<Map>()
                .map((item) => SyncPushResult.fromJson(item))
                .toList(growable: false)
          : const [],
    );
  }
}

final class SyncPushResponse {
  const SyncPushResponse({required this.results});

  final List<SyncPushResult> results;
}

final class SyncPushResult {
  const SyncPushResult({
    required this.entityName,
    required this.clientId,
    required this.entityId,
    required this.status,
  });

  final String entityName;
  final String? clientId;
  final String? entityId;
  final SyncPushStatus status;

  factory SyncPushResult.fromJson(Map<dynamic, dynamic> json) {
    return SyncPushResult(
      entityName: json['entityName']?.toString() ?? '',
      clientId: json['clientId']?.toString(),
      entityId: json['entityId']?.toString(),
      status: syncPushStatusFromApi(json['status']),
    );
  }
}

enum SyncPushStatus { synced, conflict, failed }

SyncPushStatus syncPushStatusFromApi(Object? value) {
  return switch (value) {
    'Synced' => SyncPushStatus.synced,
    'Conflict' => SyncPushStatus.conflict,
    _ => SyncPushStatus.failed,
  };
}

Map<String, Object?> _unwrapData(Map<String, Object?> json) {
  final data = json['data'];
  if (data is Map<String, Object?>) {
    return data;
  }
  if (data is Map) {
    return Map<String, Object?>.from(data);
  }
  return json;
}
