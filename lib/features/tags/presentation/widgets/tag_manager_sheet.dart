import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
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
          FlowFiButton(
            label: 'Thêm danh mục',
            variant: FlowFiButtonVariant.outline,
            icon: Icons.add_rounded,
            onPressed: () => showFlowFiFormSheet<void>(
              context: context,
              title: 'Thêm danh mục',
              child: const _TagForm(),
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const FlowFiInlineEmptyState(
              icon: Icons.sell_outlined,
              title: 'Chưa có danh mục',
              message: 'Tạo danh mục để phân loại giao dịch.',
            ),
          for (final tag in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FlowFiListItemCard(
                icon: tag.type == MoneyFlowType.income
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                tone: tag.type == MoneyFlowType.income
                    ? FlowFiTone.positive
                    : FlowFiTone.negative,
                title: tag.name,
                subtitle: tag.type == MoneyFlowType.income
                    ? 'Thu nhập'
                    : 'Chi tiêu',
                action: FlowFiActionMenu(
                  tooltip: 'Tùy chọn danh mục',
                  actions: [
                    FlowFiMenuAction(
                      label: 'Sửa',
                      icon: Icons.edit_rounded,
                      onSelected: () => showFlowFiFormSheet<void>(
                        context: context,
                        title: 'Sửa danh mục',
                        child: _TagForm(tag: tag),
                      ),
                    ),
                    FlowFiMenuAction(
                      label: 'Xóa',
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                      onSelected: () => _deleteTag(context, ref, tag),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteTag(BuildContext context, WidgetRef ref, Tag tag) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Xóa danh mục?',
      message: 'Danh mục này sẽ bị xóa khỏi FlowFi.',
    );
    if (confirmed) {
      try {
        await ref.read(tagsProvider.notifier).deleteTag(tag.id);
      } catch (_) {
        if (context.mounted) {
          showGenericMutationError(context);
        }
      }
    }
  }
}

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
          FlowFiTextField(
            label: 'Tên danh mục',
            controller: _nameController,
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          FlowFiSelectField<MoneyFlowType>(
            label: 'Loại',
            value: _type,
            items: const [
              FlowFiSelectItem(
                value: MoneyFlowType.expense,
                label: 'Chi tiêu',
                icon: Icons.trending_down_rounded,
              ),
              FlowFiSelectItem(
                value: MoneyFlowType.income,
                label: 'Thu nhập',
                icon: Icons.trending_up_rounded,
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 18),
          FlowFiButton(
            label: widget.tag == null ? 'Tạo danh mục' : 'Lưu thay đổi',
            isLoading: _isSubmitting,
            onPressed: _submit,
            icon: Icons.check_rounded,
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
    return const FlowFiInlineLoading(label: 'Đang tải danh mục');
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowFiInlineError(
      message: 'Không tải được danh mục.',
      onRetry: onRetry,
    );
  }
}
