import 'package:flutter/material.dart';

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
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(actionLabel),
            ),
          ],
        ),
      ) ??
      false;
}
