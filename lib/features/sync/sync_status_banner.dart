import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/presentation/widgets/forui_controls.dart';
import 'sync_status_provider.dart';

class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStatusProvider);
    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        if (status.isOnline &&
            status.pendingCount == 0 &&
            !status.isSynchronizing &&
            status.error == null) {
          return const SizedBox.shrink();
        }
        final tone = !status.isOnline || status.error != null
            ? FlowFiTone.warning
            : FlowFiTone.info;
        final toneStyle = flowFiToneStyle(context, tone);
        final text = status.isSynchronizing
            ? 'Đang đồng bộ ${status.pendingCount} thao tác...'
            : !status.isOnline
            ? 'Đang ngoại tuyến. Thao tác mới sẽ chờ đồng bộ.'
            : status.error != null
            ? 'Đồng bộ chưa thành công. ${status.pendingCount} thao tác đang chờ.'
            : '${status.pendingCount} thao tác đang chờ đồng bộ.';
        return Material(
          color: toneStyle.background,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    status.isSynchronizing || status.isOnline
                        ? Icons.sync_rounded
                        : Icons.wifi_off_rounded,
                    size: 18,
                    color: toneStyle.foreground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: toneStyle.foreground,
                      ),
                    ),
                  ),
                  if (status.isOnline &&
                      status.pendingCount > 0 &&
                      !status.isSynchronizing) ...[
                    const SizedBox(width: 8),
                    FlowFiButton(
                      label: status.error == null ? 'Đồng bộ' : 'Thử lại',
                      onPressed: () =>
                          ref.read(syncStatusProvider.notifier).synchronize(),
                      fullWidth: false,
                      variant: FlowFiButtonVariant.ghost,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
