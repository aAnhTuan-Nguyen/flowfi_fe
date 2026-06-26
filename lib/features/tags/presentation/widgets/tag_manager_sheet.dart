import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../domain/entities/tag.dart';
import '../providers/tags_provider.dart';

class TagManagerSheet extends ConsumerWidget {
  const TagManagerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    return tags.when(
      loading: () => const _InlineLoading(),
      error: (_, _) =>
          _InlineError(onRetry: () => ref.read(tagsProvider.notifier).reload()),
      data: (items) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showFlowFiFormSheet<void>(
                context: context,
                title: 'Add tag',
                child: const _TagForm(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add tag'),
            ),
          ),
          const SizedBox(height: 12),
          for (final tag in items)
            ListTile(
              title: Text(tag.name),
              subtitle: Text(
                tag.type == MoneyFlowType.income ? 'Income' : 'Expense',
              ),
              trailing: PopupMenuButton<_TagAction>(
                onSelected: (action) async {
                  switch (action) {
                    case _TagAction.edit:
                      await showFlowFiFormSheet<void>(
                        context: context,
                        title: 'Edit tag',
                        child: _TagForm(tag: tag),
                      );
                    case _TagAction.delete:
                      final confirmed = await confirmDestructiveAction(
                        context,
                        title: 'Delete tag?',
                        message: 'This removes the tag from FlowFi.',
                      );
                      if (confirmed) {
                        try {
                          await ref
                              .read(tagsProvider.notifier)
                              .deleteTag(tag.id);
                        } catch (_) {
                          if (context.mounted) {
                            showGenericMutationError(context);
                          }
                        }
                      }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: _TagAction.edit, child: Text('Edit')),
                  PopupMenuItem(
                    value: _TagAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum _TagAction { edit, delete }

class _TagForm extends ConsumerStatefulWidget {
  const _TagForm({this.tag});

  final Tag? tag;

  @override
  ConsumerState<_TagForm> createState() => _TagFormState();
}

class _TagFormState extends ConsumerState<_TagForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late MoneyFlowType _type;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _type = widget.tag?.type == MoneyFlowType.income
        ? MoneyFlowType.income
        : MoneyFlowType.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MoneyFlowType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(
                value: MoneyFlowType.expense,
                child: Text('Expense'),
              ),
              DropdownMenuItem(
                value: MoneyFlowType.income,
                child: Text('Income'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(widget.tag == null ? 'Create tag' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      if (widget.tag == null) {
        await ref
            .read(tagsProvider.notifier)
            .createTag(name: _nameController.text.trim(), type: _type);
      } else {
        await ref
            .read(tagsProvider.notifier)
            .updateTag(
              widget.tag!.id,
              name: _nameController.text.trim(),
              type: _type,
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowFiCard(
      child: Row(
        children: [
          const Expanded(child: Text('Could not load this section.')),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
