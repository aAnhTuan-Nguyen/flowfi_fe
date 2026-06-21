import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/example_item.dart';
import '../../domain/usecases/get_example_items_use_case.dart';

final getExampleItemsUseCaseProvider = Provider<GetExampleItemsUseCase>(
  (ref) => serviceLocator<GetExampleItemsUseCase>(),
);

class ExampleItemsNotifier extends AsyncNotifier<List<ExampleItem>> {
  @override
  Future<List<ExampleItem>> build() {
    return ref.watch(getExampleItemsUseCaseProvider)();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getExampleItemsUseCaseProvider)(),
    );
  }
}

final exampleItemsProvider =
    AsyncNotifierProvider<ExampleItemsNotifier, List<ExampleItem>>(
      ExampleItemsNotifier.new,
    );
