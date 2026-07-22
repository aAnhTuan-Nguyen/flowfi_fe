import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../../sync/sync_status_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../domain/entities/voice_transaction_import.dart';
import '../providers/voice_transaction_import_provider.dart';

class VoiceTransactionImportSheet extends ConsumerStatefulWidget {
  const VoiceTransactionImportSheet({super.key});

  @override
  ConsumerState<VoiceTransactionImportSheet> createState() =>
      _VoiceTransactionImportSheetState();
}

class _VoiceTransactionImportSheetState
    extends ConsumerState<VoiceTransactionImportSheet> {
  final _recorder = AudioRecorder();
  String? _walletId;
  String? _recordedPath;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _recording = false;
  bool _confirming = false;
  String? _localError;

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_recorder.dispose());
    final path = _recordedPath;
    if (path != null) unawaited(File(path).delete().catchError((_) => File(path)));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final importState = ref.watch(voiceTransactionImportProvider);
    final result = importState.value;

    return wallets.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải ví'),
      error: (_, _) => const Text('Không tải được danh sách ví.'),
      data: (items) {
        if (items.isEmpty) return const Text('Hãy tạo ít nhất một ví trước khi ghi âm giao dịch.');
        _walletId ??= items.first.id;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result == null) ...[
              FlowFiSelectField<String>(
                label: 'Ví nhận giao dịch',
                value: _walletId,
                items: [
                  for (final wallet in items)
                    FlowFiSelectItem(
                      value: wallet.id,
                      label: wallet.name,
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                ],
                onChanged: _recording
                    ? null
                    : (value) => setState(() => _walletId = value),
              ),
              const SizedBox(height: 20),
              _RecorderPanel(
                recording: _recording,
                processing: importState.isLoading,
                elapsedSeconds: _elapsedSeconds,
                onTap: importState.isLoading ? null : _toggleRecording,
              ),
              const SizedBox(height: 12),
              Text(
                importState.isLoading
                    ? 'Đang nhận diện giọng nói và tạo bản nháp…'
                    : _recording
                    ? 'Hãy nói rõ số tiền và nội dung giao dịch'
                    : 'Chạm micro để bắt đầu ghi âm',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (_localError != null || importState.hasError) ...[
                const SizedBox(height: 12),
                _ErrorMessage(
                  message: _localError ?? 'Không xử lý được bản ghi. Vui lòng thử lại.',
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Ví dụ: “Ăn trưa 50 nghìn bằng ví tiền mặt”.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ] else
              _VoiceResult(
                result: result,
                confirming: _confirming,
                onConfirm: _confirm,
                onRetry: _reset,
              ),
          ],
        );
      },
    );
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      await _stopAndSubmit();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() => _localError = null);
    if (!await _recorder.hasPermission()) {
      setState(() => _localError = 'FlowFi cần quyền microphone để ghi âm.');
      return;
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}${Platform.pathSeparator}flowfi-voice-${DateTime.now().millisecondsSinceEpoch}.m4a';
    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: path,
      );
      _recordedPath = path;
      _elapsedSeconds = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsedSeconds++);
      });
      setState(() => _recording = true);
    } catch (_) {
      setState(() => _localError = 'Không thể bắt đầu ghi âm.');
    }
  }

  Future<void> _stopAndSubmit() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (mounted) setState(() => _recording = false);
    if (path == null || _elapsedSeconds < 1 || _walletId == null) {
      setState(() => _localError = 'Bản ghi quá ngắn. Hãy nói lại giao dịch.');
      return;
    }
    try {
      final bytes = await File(path).readAsBytes();
      await ref.read(voiceTransactionImportProvider.notifier).submit(
        walletId: _walletId!,
        voice: AiVoiceFile(
          name: path.split(Platform.pathSeparator).last,
          mimeType: 'audio/mp4',
          bytes: bytes,
        ),
      );
      ref.invalidate(transactionsProvider);
    } catch (_) {
      if (mounted) setState(() => _localError = 'Không thể nhận diện giao dịch. Hãy thử nói rõ hơn.');
    }
  }

  Future<void> _confirm() async {
    final transaction = ref.read(voiceTransactionImportProvider).value?.transaction;
    if (transaction == null) return;
    setState(() => _confirming = true);
    try {
      await ref.read(transactionsProvider.notifier).confirmTransaction(transaction.id);
      ref.invalidate(syncStatusProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _confirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xác nhận giao dịch.')),
        );
      }
    }
  }

  void _reset() {
    ref.read(voiceTransactionImportProvider.notifier).clear();
    setState(() {
      _localError = null;
      _elapsedSeconds = 0;
    });
  }
}

class _RecorderPanel extends StatelessWidget {
  const _RecorderPanel({
    required this.recording,
    required this.processing,
    required this.elapsedSeconds,
    required this.onTap,
  });
  final bool recording;
  final bool processing;
  final int elapsedSeconds;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = recording ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Column(children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 7,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 84,
              height: 84,
              child: processing
                  ? const Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Icon(recording ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 38),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(_duration(elapsedSeconds), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
      ]),
    );
  }
}

class _VoiceResult extends StatelessWidget {
  const _VoiceResult({
    required this.result,
    required this.confirming,
    required this.onConfirm,
    required this.onRetry,
  });
  final VoiceTransactionImport result;
  final bool confirming;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final transaction = result.transaction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: FlowFiColors.positiveSurface, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: FlowFiColors.income),
            const SizedBox(width: 10),
            Expanded(child: Text('Đã tạo bản nháp. Hãy kiểm tra trước khi xác nhận.', style: Theme.of(context).textTheme.bodyMedium)),
          ]),
        ),
        const SizedBox(height: 16),
        Text('Nội dung nhận diện', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Text('“${result.transcript}”', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        FlowFiCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const FlowFiIconBadge(icon: Icons.mic_rounded, tone: FlowFiTone.info),
              const SizedBox(width: 12),
              Expanded(child: Text(transaction.title, style: Theme.of(context).textTheme.titleMedium)),
              FlowFiAmountText(amount: transaction.amount),
            ]),
            const SizedBox(height: 10),
            Text(transaction.description ?? 'Giao dịch tạo từ giọng nói', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            const FlowFiStatusBadge(label: 'Bản nháp', tone: FlowFiTone.warning),
          ]),
        ),
        const SizedBox(height: 18),
        FlowFiButton(label: 'Xác nhận giao dịch', icon: Icons.check_rounded, isLoading: confirming, onPressed: onConfirm),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: confirming ? null : onRetry, icon: const Icon(Icons.replay_rounded), label: const Text('Ghi âm lại'))),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
    child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
  );
}

String _duration(int seconds) => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
