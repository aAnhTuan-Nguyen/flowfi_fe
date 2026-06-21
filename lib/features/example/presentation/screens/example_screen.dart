import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/example_item.dart';
import '../providers/example_items_provider.dart';

class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(exampleItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('FlowFi')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disposable architecture example',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Use this feature as a reference, then delete it when the '
                'first real FlowFi feature is ready.',
              ),
              const SizedBox(height: 24),
              Expanded(child: _ExampleItems(items: items)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleItems extends ConsumerWidget {
  const _ExampleItems({required this.items});

  final AsyncValue<List<ExampleItem>> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return items.when(
      data: (value) {
        if (value.isEmpty) {
          return const Center(child: Text('No example items.'));
        }
        return ListView.separated(
          itemCount: value.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final item = value[index];
            return ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: Text(item.title),
            );
          },
        );
      },
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load the architecture example.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.read(exampleItemsProvider.notifier).reload(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
