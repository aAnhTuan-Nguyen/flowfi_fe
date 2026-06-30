import 'money_flow_type.dart';

BigInt parseMoneyMinorUnits(String value) {
  final trimmed = value.trim().replaceAll(',', '');
  if (trimmed.isEmpty) {
    return BigInt.zero;
  }
  final negative = trimmed.startsWith('-');
  final unsigned = negative ? trimmed.substring(1) : trimmed;
  final parts = unsigned.split('.');
  final whole = parts.isEmpty || parts.first.isEmpty ? '0' : parts.first;
  final fraction = parts.length > 1 ? parts[1] : '';
  final normalizedFraction = '${fraction}00'.substring(0, 2);
  final minorUnits =
      (BigInt.tryParse(whole) ?? BigInt.zero) * BigInt.from(100) +
      (BigInt.tryParse(normalizedFraction) ?? BigInt.zero);
  return negative ? -minorUnits : minorUnits;
}

String formatMoneyMinorUnits(BigInt value) {
  final negative = value < BigInt.zero;
  final absolute = negative ? -value : value;
  final whole = absolute ~/ BigInt.from(100);
  final fraction = (absolute % BigInt.from(100)).toInt();
  final sign = negative ? '-' : '';
  if (fraction == 0) {
    return '$sign$whole';
  }
  return '$sign$whole.${fraction.toString().padLeft(2, '0')}';
}

String applyTransactionEffect({
  required String balance,
  required String amount,
  required MoneyFlowType type,
}) {
  final balanceMinorUnits = parseMoneyMinorUnits(balance);
  final amountMinorUnits = parseMoneyMinorUnits(amount);
  final next = switch (type) {
    MoneyFlowType.income => balanceMinorUnits + amountMinorUnits,
    MoneyFlowType.expense => balanceMinorUnits - amountMinorUnits,
    MoneyFlowType.unknown => balanceMinorUnits,
  };
  return formatMoneyMinorUnits(next);
}
