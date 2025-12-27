import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class Money {
  Money._();

  static Decimal? parseToDecimal(String input) {
    final cleaned = input.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    return Decimal.tryParse(cleaned);
  }

  static String format(Decimal value, {required String currencyCode}) {
    // Fast conversion without parsing strings manually
    final numValue = value.toDouble();
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: _symbolFor(currencyCode),
      name: currencyCode,
      decimalDigits: 2,
    );
    return formatter.format(numValue);
  }

  static String _symbolFor(String code) {
    switch (code) {
      case 'SAR':
        return 'SAR ';
      case 'USD':
        return '\$';
      default:
        return '$code ';
    }
  }

  static Decimal round2(Decimal value) {
    return Decimal.parse(value.toStringAsFixed(2));
  }
}
