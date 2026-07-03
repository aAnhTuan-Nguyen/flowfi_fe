import 'package:dio/dio.dart';

import 'data/offline_sync_service.dart';

enum SyncFailureKind {
  network,
  authentication,
  validation,
  staleReference,
  conflict,
  server,
  unknown,
}

final class SyncFailure {
  const SyncFailure({
    required this.kind,
    required this.title,
    required this.message,
    this.statusCode,
    this.code,
    this.requestId,
    this.failedCount = 0,
    this.conflictCount = 0,
  });

  final SyncFailureKind kind;
  final String title;
  final String message;
  final int? statusCode;
  final String? code;
  final String? requestId;
  final int failedCount;
  final int conflictCount;

  String? get debugLabel {
    final parts = <String>[
      if (statusCode != null) 'HTTP $statusCode',
      if (code != null && code!.isNotEmpty) code!,
      if (requestId != null && requestId!.isNotEmpty) 'requestId: $requestId',
    ];
    return parts.isEmpty ? null : parts.join(' | ');
  }

  static SyncFailure fromError(Object error) {
    if (error is SyncFailure) {
      return error;
    }
    if (error is DioException) {
      return _fromDioException(error);
    }
    return const SyncFailure(
      kind: SyncFailureKind.unknown,
      title: 'Đồng bộ chưa thành công',
      message: 'Đồng bộ chưa hoàn tất. Dữ liệu được giữ lại để thử lại.',
    );
  }

  static SyncFailure fromSummary(OfflineSyncSummary summary) {
    if (summary.conflictCount > 0) {
      return SyncFailure(
        kind: SyncFailureKind.conflict,
        title: 'Cần xử lý xung đột',
        message: 'Có thao tác cần xử lý xung đột trước khi đồng bộ tiếp.',
        failedCount: summary.failedCount,
        conflictCount: summary.conflictCount,
      );
    }
    return SyncFailure(
      kind: SyncFailureKind.unknown,
      title: 'Đồng bộ chưa thành công',
      message:
          'Backend chưa nhận một số thao tác chờ. Dữ liệu được giữ lại để thử lại.',
      failedCount: summary.failedCount,
      conflictCount: summary.conflictCount,
    );
  }

  static SyncFailure _fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final root = _asMap(error.response?.data);
    final errorBody = _asMap(root?['error']);
    final meta = _asMap(root?['meta']);
    final code = errorBody?['code']?.toString();
    final backendMessage = errorBody?['message']?.toString();
    final requestId = meta?['requestId']?.toString();
    final lowerCode = code?.toLowerCase() ?? '';
    final lowerMessage = backendMessage?.toLowerCase() ?? '';

    if (error.response == null) {
      return SyncFailure(
        kind: SyncFailureKind.network,
        title: 'Chưa kết nối được backend',
        message: 'Kiểm tra mạng rồi thử đồng bộ lại.',
        code: code,
        requestId: requestId,
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      return SyncFailure(
        kind: SyncFailureKind.authentication,
        title: 'Phiên đăng nhập cần làm mới',
        message: 'Đăng nhập lại rồi thử đồng bộ.',
        statusCode: statusCode,
        code: code,
        requestId: requestId,
      );
    }
    if (statusCode == 404 ||
        lowerCode.contains('not_found') ||
        lowerMessage.contains('wallet not found') ||
        lowerMessage.contains('tag not found')) {
      return SyncFailure(
        kind: SyncFailureKind.staleReference,
        title: 'Dữ liệu chờ không còn khớp',
        message: 'Một thao tác chờ dùng ví hoặc danh mục không còn hợp lệ.',
        statusCode: statusCode,
        code: code,
        requestId: requestId,
      );
    }
    if (statusCode == 400 || lowerCode.contains('validation')) {
      return SyncFailure(
        kind: SyncFailureKind.validation,
        title: 'Dữ liệu chờ chưa hợp lệ',
        message:
            'Một thao tác chờ có dữ liệu chưa hợp lệ. Dữ liệu được giữ lại để bạn kiểm tra.',
        statusCode: statusCode,
        code: code,
        requestId: requestId,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return SyncFailure(
        kind: SyncFailureKind.server,
        title: 'Backend chưa xử lý được đồng bộ',
        message: 'Thử lại sau ít phút. Dữ liệu chờ vẫn được giữ lại.',
        statusCode: statusCode,
        code: code,
        requestId: requestId,
      );
    }
    return SyncFailure(
      kind: SyncFailureKind.unknown,
      title: 'Đồng bộ chưa thành công',
      message: 'Đồng bộ chưa hoàn tất. Dữ liệu được giữ lại để thử lại.',
      statusCode: statusCode,
      code: code,
      requestId: requestId,
    );
  }
}

Map<Object?, Object?>? _asMap(Object? value) {
  return value is Map ? value : null;
}
