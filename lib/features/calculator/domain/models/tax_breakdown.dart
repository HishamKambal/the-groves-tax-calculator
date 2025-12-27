import 'package:decimal/decimal.dart';

class TaxBreakdown {
  final Decimal inclusive;
  final Decimal base;
  final Decimal excise;
  final Decimal vat;

  const TaxBreakdown({
    required this.inclusive,
    required this.base,
    required this.excise,
    required this.vat,
  });

  Decimal get totalTax => excise + vat;
}
