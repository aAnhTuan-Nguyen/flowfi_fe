import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            status.error == null) {
          return const SizedBox.shrink();
        }
        final colors = Theme.of(context).colorScheme;
        final text = !status.isOnline
            ? 'Đang ngoại tuyến · thao tác mới sẽ chờ đồng bộ'
            : status.error != null
            ? 'Đồng bộ chưa thành công · ${status.pendingCount} thao tác đang chờ'
            : '${status.pendingCount} thao tác đang chờ đồng bộ';
        return Material(
          color: colors.tertiaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    status.isOnline
                        ? Icons.sync_rounded
                        : Icons.wifi_off_rounded,
                    size: 18,
                    color: colors.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onTertiaryContainer,
                      ),
                    ),
                  ),
                  if (status.isOnline && status.pendingCount > 0)
                    TextButton(
                      onPressed: () =>
                          ref.read(syncStatusProvider.notifier).synchronize(),
                      child: const Text('Đồng bộ'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
