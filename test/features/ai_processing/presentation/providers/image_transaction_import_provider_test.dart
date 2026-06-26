import 'package:flowfi_fe/features/ai_processing/domain/entities/ai_image_file.dart';
import 'package:flowfi_fe/features/ai_processing/domain/entities/image_transaction_import.dart';
import 'package:flowfi_fe/features/ai_processing/domain/repositories/ai_processing_repository.dart';
import 'package:flowfi_fe/features/ai_processing/presentation/providers/image_transaction_import_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uploads image through repository and exposes result', () async {
    final repository = FakeAiProcessingRepository();
    final container = ProviderContainer(
      overrides: [aiProcessingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(imageTransactionImportProvider.notifier)
        .createTransactionsFromImage(
          walletId: 'wallet-1',
          image: const AiImageFile(
            name: 'receipt.png',
            bytes: [1, 2, 3],
            mimeType: 'image/png',
          ),
        );

    expect(result.aiRequestId, 'request-1');
    expect(repository.events, ['wallet-1:receipt.png']);
    expect(
      container.read(imageTransactionImportProvider).value?.aiResultId,
      'result-1',
    );
  });

  test('rejects unsupported image types before calling repository', () async {
    final repository = FakeAiProcessingRepository();
    final container = ProviderContainer(
      overrides: [aiProcessingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(
      () => container
          .read(imageTransactionImportProvider.notifier)
          .createTransactionsFromImage(
            walletId: 'wallet-1',
            image: const AiImageFile(
              name: 'receipt.gif',
              bytes: [1, 2, 3],
              mimeType: 'image/gif',
            ),
          ),
      throwsA(isA<AiImageValidationException>()),
    );
    expect(repository.events, isEmpty);
  });
}

final class FakeAiProcessingRepository implements AiProcessingRepository {
  final events = <String>[];

  @override
  Future<ImageTransactionImport> createTransactionsFromImage({
    required String walletId,
    required AiImageFile image,
  }) async {
    events.add('$walletId:${image.name}');
    return const ImageTransactionImport(
      aiRequestId: 'request-1',
      aiResultId: 'result-1',
      imageUrl: 'local://receipt.png',
      createdTransactions: [],
    );
  }
}
