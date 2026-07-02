import 'package:flutter/material.dart';

import 'forui_controls.dart';

final _amountPattern = RegExp(r'^\d+(\.\d{1,2})?$');

String? requiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Vui lòng nhập thông tin này';
  }
  return null;
}

String? requiredAmount(String? value) {
  final required = requiredText(value);
  if (required != null) {
    return required;
  }
  if (!_amountPattern.hasMatch(value!.trim())) {
    return 'Số tiền chưa hợp lệ';
  }
  return null;
}

String? optionalAmount(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  if (!_amountPattern.hasMatch(trimmed)) {
    return 'Số tiền chưa hợp lệ';
  }
  return null;
}

String? emptyToNull(String value) => value.isEmpty ? null : value;

void showGenericMutationError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Không thể lưu thay đổi. Vui lòng thử lại.')),
  );
}

Future<bool> confirmDestructiveAction(
  BuildContext context, {
  required String title,
  required String message,
  String actionLabel = 'Xóa',
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FlowFiButton(
                        label: 'Hủy',
                        variant: FlowFiButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FlowFiButton(
                        label: actionLabel,
                        variant: FlowFiButtonVariant.destructive,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}
