import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../shared/presentation/widgets/feature_states.dart';
import '../shared/presentation/widgets/forui_controls.dart';
import 'sync_failure.dart';
import 'sync_status_provider.dart';

class SyncStatusHost extends ConsumerStatefulWidget {
  const SyncStatusHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncStatusHost> createState() => _SyncStatusHostState();
}

class _SyncStatusHostState extends ConsumerState<SyncStatusHost> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SyncStatusState>>(syncStatusProvider, (
      previous,
      next,
    ) {
      final previousStatus = _statusData(previous);
      final status = _statusData(next);
      if (status == null || !mounted) {
        return;
      }
      final failure = status.error;
      if (failure != null &&
          _failureSignature(previousStatus?.error) !=
              _failureSignature(failure)) {
        _showFailureToast(context, failure);
        return;
      }
      if (failure == null &&
          status.lastSyncedCount > 0 &&
          previousStatus?.lastSyncedCount != status.lastSyncedCount) {
        _showSuccessToast(context, status.lastSyncedCount);
      }
    });
    return widget.child;
  }

  void _showFailureToast(BuildContext context, SyncFailure failure) {
    showFToast(
      context: context,
      alignment: FToastAlignment.bottomCenter,
      variant: FToastVariant.destructive,
      icon: const Icon(Icons.sync_problem_rounded),
      title: Text(failure.title),
      description: Text(failure.message),
      suffixBuilder: (_, entry) => FButton(
        onPress: () {
          entry.dismiss();
          ref.read(syncStatusProvider.notifier).synchronize();
        },
        variant: FButtonVariant.outline,
        size: FButtonSizeVariant.sm,
        mainAxisSize: MainAxisSize.min,
        child: const Text('Thử lại'),
      ),
    );
  }

  void _showSuccessToast(BuildContext context, int syncedCount) {
    showFToast(
      context: context,
      alignment: FToastAlignment.bottomCenter,
      icon: const Icon(Icons.check_circle_rounded),
      title: Text('Đã đồng bộ $syncedCount thao tác.'),
    );
  }
}

class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStatusProvider);
    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        final presentation = _SyncStatusPresentation.fromStatus(status);
        if (presentation == null) {
          return const SizedBox.shrink();
        }
        final toneStyle = flowFiToneStyle(context, presentation.tone);
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            key: const ValueKey('sync-status-chip'),
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSyncStatusDetails(context),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                constraints: const BoxConstraints(minHeight: 40, maxWidth: 320),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: toneStyle.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: toneStyle.foreground),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F172015),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (presentation.showProgress)
                      SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: toneStyle.foreground,
                        ),
                      )
                    else
                      Icon(
                        presentation.icon,
                        size: 17,
                        color: toneStyle.foreground,
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        presentation.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: toneStyle.foreground,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showSyncStatusDetails(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final status = ref.watch(syncStatusProvider).value;
          final presentation = status == null
              ? null
              : _SyncStatusPresentation.fromStatus(status);
          final colors = Theme.of(context).colorScheme;
          final failure = status?.error;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: colors.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Trạng thái đồng bộ',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        FlowFiIconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          tooltip: 'Đóng',
                          icon: Icons.close_rounded,
                          variant: FlowFiButtonVariant.ghost,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (presentation != null)
                      FlowFiStatusBadge(
                        label: presentation.title,
                        icon: presentation.icon,
                        tone: presentation.tone,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _detailMessage(status),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (kDebugMode && failure?.debugLabel != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        failure!.debugLabel!,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                    if (status != null &&
                        status.isOnline &&
                        status.pendingCount > 0 &&
                        !status.isSynchronizing) ...[
                      const SizedBox(height: 16),
                      FlowFiButton(
                        label: status.error == null
                            ? 'Đồng bộ ngay'
                            : 'Thử lại',
                        icon: Icons.sync_rounded,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          ref.read(syncStatusProvider.notifier).synchronize();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

String _detailMessage(SyncStatusState? status) {
  if (status == null) {
    return 'Đang đọc trạng thái đồng bộ.';
  }
  final failure = status.error;
  if (failure != null) {
    return failure.message;
  }
  if (!status.isOnline) {
    return status.pendingCount > 0
        ? 'Thiết bị đang ngoại tuyến. Thao tác mới sẽ được giữ lại và tự đồng bộ khi có mạng.'
        : 'Thiết bị đang ngoại tuyến. Dữ liệu mới sẽ chờ đồng bộ khi có mạng.';
  }
  if (status.isSynchronizing) {
    return 'FlowFi đang gửi các thao tác chờ lên backend.';
  }
  if (status.pendingCount > 0) {
    return 'FlowFi sẽ tự đồng bộ các thao tác chờ khi backend sẵn sàng.';
  }
  return 'Dữ liệu hiện đã được đồng bộ.';
}

String? _failureSignature(SyncFailure? failure) {
  if (failure == null) {
    return null;
  }
  return [
    failure.kind.name,
    failure.statusCode,
    failure.code,
    failure.requestId,
    failure.failedCount,
    failure.conflictCount,
  ].join('|');
}

SyncStatusState? _statusData(AsyncValue<SyncStatusState>? value) {
  return value is AsyncData<SyncStatusState> ? value.value : null;
}

final class _SyncStatusPresentation {
  const _SyncStatusPresentation({
    required this.label,
    required this.title,
    required this.icon,
    required this.tone,
    this.showProgress = false,
  });

  final String label;
  final String title;
  final IconData icon;
  final FlowFiTone tone;
  final bool showProgress;

  static _SyncStatusPresentation? fromStatus(SyncStatusState status) {
    if (status.isOnline &&
        status.pendingCount == 0 &&
        !status.isSynchronizing &&
        status.error == null) {
      return null;
    }
    if (status.isSynchronizing) {
      return const _SyncStatusPresentation(
        label: 'Đang đồng bộ',
        title: 'Đang đồng bộ',
        icon: Icons.sync_rounded,
        tone: FlowFiTone.info,
        showProgress: true,
      );
    }
    if (!status.isOnline) {
      return _SyncStatusPresentation(
        label: status.pendingCount > 0
            ? '${status.pendingCount} chờ đồng bộ'
            : 'Đang ngoại tuyến',
        title: 'Đang ngoại tuyến',
        icon: Icons.wifi_off_rounded,
        tone: FlowFiTone.warning,
      );
    }
    if (status.error != null) {
      return _SyncStatusPresentation(
        label: status.pendingCount > 0
            ? '${status.pendingCount} chờ đồng bộ'
            : 'Đồng bộ lỗi',
        title: status.error!.title,
        icon: Icons.sync_problem_rounded,
        tone: FlowFiTone.warning,
      );
    }
    return _SyncStatusPresentation(
      label: '${status.pendingCount} chờ đồng bộ',
      title: 'Chờ đồng bộ',
      icon: Icons.sync_rounded,
      tone: FlowFiTone.info,
    );
  }
}
