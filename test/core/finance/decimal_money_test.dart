import 'package:flowfi_fe/core/finance/decimal_money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeEditableMoneyAmount', () {
    test('removes backend zero decimal suffix', () {
      expect(normalizeEditableMoneyAmount('30000000000.00'), '30000000000');
      expect(normalizeEditableMoneyAmount('150000.00'), '150000');
    });

    test('preserves meaningful decimal digits', () {
      expect(normalizeEditableMoneyAmount('150000.50'), '150000.50');
    });

    test('keeps a new empty amount empty', () {
      expect(normalizeEditableMoneyAmount(''), isEmpty);
    });
  });
}
