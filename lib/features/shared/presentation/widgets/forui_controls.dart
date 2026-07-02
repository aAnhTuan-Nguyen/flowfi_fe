import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

enum FlowFiTone { neutral, positive, negative, warning, info }

class FlowFiToneStyle {
  const FlowFiToneStyle({
    required this.background,
    required this.foreground,
    required this.muted,
  });

  final Color background;
  final Color foreground;
  final Color muted;
}

abstract final class FlowFiColors {
  static const income = Color(0xFF4F6F39);
  static const expense = Color(0xFFB84A3F);
  static const positiveSurface = Color(0xFFE7F1DA);
  static const warmSurface = Color(0xFFFFF6EB);
  static const imagePlaceholder = Color(0xFFE7E5DC);
  static const muted = Color(0xFF687268);
  static const mutedStrong = Color(0xFF757872);
  static const danger = Color(0xFFBA1A1A);
  static const onStrong = Color(0xFFFFFFFF);

  static const chartPalette = <Color>[
    income,
    Color(0xFF2F6F7E),
    Color(0xFFE39D36),
    Color(0xFF7B6FD6),
    Color(0xFFB85C5C),
  ];
}

FlowFiToneStyle flowFiToneStyle(BuildContext context, FlowFiTone tone) {
  final colors = Theme.of(context).colorScheme;
  return switch (tone) {
    FlowFiTone.neutral => FlowFiToneStyle(
      background: colors.surfaceContainerLow,
      foreground: colors.onSurface,
      muted: colors.onSurfaceVariant,
    ),
    FlowFiTone.positive => const FlowFiToneStyle(
      background: FlowFiColors.positiveSurface,
      foreground: FlowFiColors.income,
      muted: FlowFiColors.muted,
    ),
    FlowFiTone.negative => FlowFiToneStyle(
      background: colors.errorContainer,
      foreground: colors.error,
      muted: colors.onSurfaceVariant,
    ),
    FlowFiTone.warning => FlowFiToneStyle(
      background: colors.secondaryContainer,
      foreground: colors.tertiary,
      muted: colors.onSurfaceVariant,
    ),
    FlowFiTone.info => FlowFiToneStyle(
      background: colors.primaryContainer,
      foreground: colors.primary,
      muted: colors.onSurfaceVariant,
    ),
  };
}

class FlowFiTextField extends StatelessWidget {
  const FlowFiTextField({
    super.key,
    required this.label,
    this.hint,
    this.description,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.enabled = true,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
  });

  final String label;
  final String? hint;
  final String? description;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final control = FTextFieldControl.managed(
      controller: controller,
      initial: controller == null && initialValue != null
          ? TextEditingValue(text: initialValue!)
          : null,
      onChange: onChanged == null ? null : (value) => onChanged!(value.text),
    );
    final labelWidget = Text(label);
    final descriptionWidget = description == null ? null : Text(description!);

    if (obscureText) {
      return FTextFormField.password(
        control: control,
        label: labelWidget,
        hint: hint,
        description: descriptionWidget,
        keyboardType: keyboardType,
        textInputAction: textInputAction ?? TextInputAction.next,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        autofillHints: autofillHints ?? const [AutofillHints.password],
        enabled: enabled,
        minLines: minLines,
        maxLines: maxLines ?? 1,
        prefixBuilder: prefixIcon == null
            ? null
            : (context, style, variants, child) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: Icon(prefixIcon, size: 18),
              ),
        suffixBuilder: suffix == null
            ? FTextField.defaultObscureIconBuilder
            : (context, style, variants, child) => suffix!,
        onSaved: onSaved,
        validator: validator,
      );
    }

    return FTextFormField(
      control: control,
      label: labelWidget,
      hint: hint,
      description: descriptionWidget,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      prefixBuilder: prefixIcon == null
          ? null
          : (context, style, variants) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Icon(prefixIcon, size: 18),
            ),
      suffixBuilder: suffix == null
          ? null
          : (context, style, variants) => suffix!,
      onSaved: onSaved,
      validator: validator,
    );
  }
}

class FlowFiSelectItem<T> {
  const FlowFiSelectItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

class FlowFiSelectField<T> extends StatelessWidget {
  const FlowFiSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.description,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<FlowFiSelectItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? description;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FSelect<T>.rich(
      control: FSelectControl.lifted(
        value: value,
        onChange: onChanged ?? (_) {},
      ),
      label: Text(label),
      hint: hint,
      description: description == null ? null : Text(description!),
      enabled: enabled && onChanged != null,
      validator: validator ?? FFormFieldProperties.defaultValidator,
      format: (value) {
        return items
            .firstWhere(
              (item) => item.value == value,
              orElse: () => FlowFiSelectItem(value: value, label: '$value'),
            )
            .label;
      },
      children: [
        for (final item in items)
          FSelectItem<T>(
            value: item.value,
            prefix: item.icon == null ? null : Icon(item.icon, size: 18),
            title: Text(item.label),
            subtitle: item.subtitle == null ? null : Text(item.subtitle!),
          ),
      ],
    );
  }
}

class FlowFiCheckboxField extends StatelessWidget {
  const FlowFiCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.error,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? description;
  final String? error;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FCheckbox(
      value: value,
      enabled: enabled,
      label: Text(label),
      description: description == null ? null : Text(description!),
      error: error == null ? null : Text(error!),
      onChange: onChanged,
    );
  }
}

enum FlowFiButtonVariant { primary, secondary, outline, ghost, destructive }

class FlowFiButton extends StatelessWidget {
  const FlowFiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = FlowFiButtonVariant.primary,
    this.fullWidth = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final FlowFiButtonVariant variant;
  final bool fullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = FButton(
      onPress: isLoading ? null : onPressed,
      variant: _variant,
      size: FButtonSizeVariant.lg,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      prefix: icon == null || isLoading ? null : Icon(icon, size: 18),
      child: isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }

  FButtonVariant get _variant {
    return switch (variant) {
      FlowFiButtonVariant.primary => FButtonVariant.primary,
      FlowFiButtonVariant.secondary => FButtonVariant.secondary,
      FlowFiButtonVariant.outline => FButtonVariant.outline,
      FlowFiButtonVariant.ghost => FButtonVariant.ghost,
      FlowFiButtonVariant.destructive => FButtonVariant.destructive,
    };
  }
}

class FlowFiIconButton extends StatelessWidget {
  const FlowFiIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.variant = FlowFiButtonVariant.outline,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final FlowFiButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: FButton.icon(
        onPress: onPressed,
        variant: switch (variant) {
          FlowFiButtonVariant.primary => FButtonVariant.primary,
          FlowFiButtonVariant.secondary => FButtonVariant.secondary,
          FlowFiButtonVariant.outline => FButtonVariant.outline,
          FlowFiButtonVariant.ghost => FButtonVariant.ghost,
          FlowFiButtonVariant.destructive => FButtonVariant.destructive,
        },
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class FlowFiMenuAction {
  const FlowFiMenuAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final FutureOr<void> Function() onSelected;
  final bool destructive;
}

class FlowFiActionMenu extends StatelessWidget {
  const FlowFiActionMenu({
    super.key,
    required this.actions,
    this.tooltip = 'Tùy chọn',
    this.icon = Icons.more_horiz_rounded,
    this.variant = FlowFiButtonVariant.ghost,
  });

  final List<FlowFiMenuAction> actions;
  final String tooltip;
  final IconData icon;
  final FlowFiButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return FlowFiIconButton(
      icon: icon,
      tooltip: tooltip,
      variant: variant,
      onPressed: actions.isEmpty ? null : () => _showActions(context),
    );
  }

  Future<void> _showActions(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                for (final action in actions) ...[
                  FlowFiButton(
                    label: action.label,
                    icon: action.icon,
                    variant: action.destructive
                        ? FlowFiButtonVariant.destructive
                        : FlowFiButtonVariant.ghost,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        action.onSelected();
                      });
                    },
                  ),
                  if (action != actions.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class FlowFiDateField extends StatelessWidget {
  const FlowFiDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon = Icons.calendar_month_rounded,
    this.enabled = true,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(value, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
