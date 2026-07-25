import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../domain/entities/tag.dart';
import '../providers/tags_provider.dart';

enum _TagFilter { all, expense, income }

Future<void> showCreateTagForm(BuildContext context) {
  return showFlowFiFormSheet<void>(
    context: context,
    title: 'Thêm danh mục',
    child: const _TagForm(),
  );
}

class TagManagerSheet extends ConsumerStatefulWidget {
  const TagManagerSheet({super.key});

  @override
  ConsumerState<TagManagerSheet> createState() => _TagManagerSheetState();
}

class _TagManagerSheetState extends ConsumerState<TagManagerSheet> {
  final _searchController = TextEditingController();
  _TagFilter _filter = _TagFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider);
    return tags.when(
      loading: () => const _InlineLoading(),
      error: (_, _) =>
          _InlineError(onRetry: () => ref.read(tagsProvider.notifier).reload()),
      data: _buildContent,
    );
  }

  Widget _buildContent(List<Tag> items) {
    final query = _searchController.text.trim().toLowerCase();
    final visibleItems = items.where((tag) {
      final matchesFilter = switch (_filter) {
        _TagFilter.all => true,
        _TagFilter.expense => tag.type == MoneyFlowType.expense,
        _TagFilter.income => tag.type == MoneyFlowType.income,
      };
      return matchesFilter && tag.name.toLowerCase().contains(query);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilterSegments(
          selected: _filter,
          onSelected: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('tag-search-field'),
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm danh mục...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Xóa tìm kiếm',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _FilterMenu(
              selected: _filter,
              onSelected: (filter) => setState(() => _filter = filter),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _AddTagButton(onPressed: () => _showTagForm()),
        const SizedBox(height: 14),
        _ListSummary(count: visibleItems.length),
        const SizedBox(height: 10),
        if (visibleItems.isEmpty)
          FlowFiInlineEmptyState(
            icon: query.isEmpty
                ? Icons.sell_outlined
                : Icons.search_off_rounded,
            title: query.isEmpty
                ? 'Chưa có danh mục'
                : 'Không tìm thấy danh mục',
            message: query.isEmpty
                ? 'Tạo danh mục để phân loại giao dịch.'
                : 'Thử từ khóa hoặc bộ lọc khác.',
          )
        else
          for (final tag in visibleItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TagCard(
                tag: tag,
                onEdit: () => _showTagForm(tag),
                onDelete: () => _deleteTag(tag),
              ),
            ),
      ],
    );
  }

  void _showTagForm([Tag? tag]) {
    if (tag == null) {
      showCreateTagForm(context);
      return;
    }
    showFlowFiFormSheet<void>(
      context: context,
      title: 'Sửa danh mục',
      child: _TagForm(tag: tag),
    );
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Xóa danh mục?',
      message: 'Danh mục này sẽ bị xóa khỏi FlowFi.',
    );
    if (!confirmed) return;
    try {
      await ref.read(tagsProvider.notifier).deleteTag(tag.id);
    } catch (_) {
      if (mounted) showGenericMutationError(context);
    }
  }
}

class _FilterSegments extends StatelessWidget {
  const _FilterSegments({required this.selected, required this.onSelected});

  final _TagFilter selected;
  final ValueChanged<_TagFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          _segment(context, 'Tất cả', _TagFilter.all),
          _segment(context, 'Chi tiêu', _TagFilter.expense),
          _segment(context, 'Thu nhập', _TagFilter.income),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, _TagFilter value) {
    final colors = Theme.of(context).colorScheme;
    final active = value == selected;
    return Expanded(
      child: Material(
        color: active ? colors.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: Key('tag-filter-${value.name}'),
          onTap: () => onSelected(value),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? colors.onSurface : colors.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.selected, required this.onSelected});

  final _TagFilter selected;
  final ValueChanged<_TagFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<_TagFilter>(
      tooltip: 'Lọc danh mục',
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (_) => const [
        PopupMenuItem(value: _TagFilter.all, child: Text('Tất cả')),
        PopupMenuItem(value: _TagFilter.expense, child: Text('Chi tiêu')),
        PopupMenuItem(value: _TagFilter.income, child: Text('Thu nhập')),
      ],
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.filter_alt_outlined, color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _AddTagButton extends StatelessWidget {
  const _AddTagButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE31D3B), Color(0xFFFF7138)],
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332F050B),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(13),
          child: const SizedBox(
            width: double.infinity,
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 21),
                SizedBox(width: 7),
                Text(
                  'Thêm danh mục',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListSummary extends StatelessWidget {
  const _ListSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    return Row(
      children: [
        Icon(Icons.layers_outlined, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text('$count danh mục', style: style),
        const Spacer(),
        Icon(Icons.swap_vert_rounded, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text('Mới nhất', style: style),
      ],
    );
  }
}

class _TagCard extends StatelessWidget {
  const _TagCard({
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  final Tag tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isIncome = tag.type == MoneyFlowType.income;
    final accent = isIncome ? const Color(0xFF39C971) : const Color(0xFFFF4B50);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 4, 9),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.24),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(_iconFor(tag), color: Colors.white, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isIncome ? 'Thu nhập' : 'Chi tiêu',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontSize: 11,
                      ),
                    ),
                    _StatusChip(
                      label: tag.isDefault ? 'Mặc định' : 'Tùy chỉnh',
                    ),
                  ],
                ),
              ],
            ),
          ),
          FlowFiActionMenu(
            tooltip: 'Tùy chọn danh mục',
            actions: [
              FlowFiMenuAction(
                label: 'Sửa',
                icon: Icons.edit_rounded,
                onSelected: onEdit,
              ),
              FlowFiMenuAction(
                label: 'Xóa',
                icon: Icons.delete_outline_rounded,
                destructive: true,
                onSelected: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(Tag tag) {
    final name = tag.name.toLowerCase();
    if (name.contains('ăn') || name.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (name.contains('hóa đơn') || name.contains('bill')) {
      return Icons.receipt_long_rounded;
    }
    if (name.contains('di chuyển') || name.contains('transport')) {
      return Icons.directions_car_filled_rounded;
    }
    if (name.contains('giáo dục') || name.contains('education')) {
      return Icons.school_rounded;
    }
    if (name.contains('sức khỏe') || name.contains('health')) {
      return Icons.favorite_rounded;
    }
    if (name.contains('cà phê') || name.contains('coffee')) {
      return Icons.local_cafe_rounded;
    }
    if (name.contains('mua') || name.contains('shopping')) {
      return Icons.shopping_cart_rounded;
    }
    return tag.type == MoneyFlowType.income
        ? Icons.account_balance_wallet_rounded
        : Icons.sell_rounded;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
            key: const Key('tag-name-field'),
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
