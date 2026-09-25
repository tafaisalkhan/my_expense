import 'package:intl/intl.dart';

class CurrencyFormatters {
  static String format(double amount, {String currencySymbol = 'Rs'}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedStr = formatter.format(amount);
    // Remove .00 if whole number for clean UX
    final cleanStr = formattedStr.endsWith('.00')
        ? formattedStr.substring(0, formattedStr.length - 3)
        : formattedStr;
    return '$currencySymbol $cleanStr';
  }

  static String formatCompact(double amount, {String currencySymbol = 'Rs'}) {
    if (amount >= 1000000) {
      return '$currencySymbol ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$currencySymbol ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$currencySymbol ${amount.toStringAsFixed(0)}';
  }
}
