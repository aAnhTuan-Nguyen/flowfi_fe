import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';

/// Create New Tag screen — tag name, color picker, category grouping, suggested tags
class CreateTagScreen extends StatefulWidget {
  const CreateTagScreen({super.key});

  @override
  State<CreateTagScreen> createState() => _CreateTagScreenState();
}

class _CreateTagScreenState extends State<CreateTagScreen> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  String _selectedGroup = 'None';

  static const List<Color> _tagColors = [
    Color(0xFF22C55E), // green
    Color(0xFF3B82F6), // blue
    Color(0xFFF97316), // orange
    Color(0xFFEF4444), // red
    Color(0xFF006E2F), // dark green
    Color(0xFF1D4ED8), // indigo
  ];

  static const List<String> _suggestedTags = [
    'Coffee', 'Subway', 'Gym', 'Rent', 'Netflix',
  ];

  static const List<String> _groups = ['None', 'Food', 'Transport', 'Lifestyle', 'Bills'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: context.colors.primary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create New Tag',
          style: AppTextStyles.headlineMd(color: context.colors.primary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: context.colors.surfaceContainerLow,
              child: Icon(
                Icons.person,
                color: context.colors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Tag Name',
                      hint: 'e.g. Vacation, Gym, Work',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select Tag Color',
                      style: AppTextStyles.labelMd(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _tagColors.asMap().entries.map((entry) {
                        final isSelected = entry.key == _selectedColorIndex;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedColorIndex = entry.key,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: context.colors.onSurface,
                                      width: 3,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Category Grouping (Optional)',
                      style: AppTextStyles.labelMd(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGroup,
                          isExpanded: true,
                          style: AppTextStyles.bodyMd(
                            color: context.colors.onSurface,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: context.colors.outline,
                          ),
                          items: _groups
                              .map(
                                (g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedGroup = v ?? 'None'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Suggested Tags',
                style: AppTextStyles.labelMd(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedTags
                    .map(
                      (tag) => GestureDetector(
                        onTap: () => setState(
                          () => _nameController.text = tag,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: context.colors.outlineVariant,
                            ),
                          ),
                          child: Text(
                            '# #$tag',
                            style: AppTextStyles.labelMd(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              _buildSmartTagsBanner(),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Save Tag',
                onPressed: () => context.pop(),
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartTagsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outlined,
              color: context.colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Tags',
                  style: AppTextStyles.bodySemibold(
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'FlowFi will automatically group future transactions that match this tag name for easier budgeting.',
                  style: AppTextStyles.bodyMd(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
