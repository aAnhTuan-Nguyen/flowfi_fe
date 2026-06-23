import 'package:intl/intl.dart';

/// Currency formatting utilities for FlowFi
abstract final class CurrencyFormatter {
  static final NumberFormat _usd = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _usdCompact = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final NumberFormat _vnd = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );



  /// Format as USD: $24,562.00
  static String formatUsd(double amount) => _usd.format(amount);

  /// Format as USD compact (no decimals): $24,562
  static String formatUsdCompact(double amount) =>
      _usdCompact.format(amount);

  /// Format as VND: ₫2,850,000
  static String formatVnd(double amount) => _vnd.format(amount);

  /// Format signed amount: +$4,200.00 or -$64.20
  static String formatSigned(double amount) {
    final formatted = _usd.format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Format as percentage: 85.0%
  static String formatPercent(double value) =>
      '${(value * 100).toStringAsFixed(0)}%';

  /// Format compact notation: $12.4M, $1.2K
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatUsd(amount);
  }
}
