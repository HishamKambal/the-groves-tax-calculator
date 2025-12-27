import 'package:decimal/decimal.dart';

import '../../../../core/utils/money.dart';
import '../models/cart_item.dart';
import '../models/tax_breakdown.dart';

class TaxConfig {
  final Decimal vatRate; // e.g. 0.15
  final Decimal tobaccoExciseRate; // e.g. 1.00 (100% of base)
  final Decimal tobaccoMultiplier; // e.g. 2.30 (confirmed)
  final String currencyCode;

  const TaxConfig({
    required this.vatRate,
    required this.tobaccoExciseRate,
    required this.tobaccoMultiplier,
    required this.currencyCode,
  });
}

class TaxCalculator {
  const TaxCalculator();

  TaxBreakdown calculate({
    required Decimal inclusivePrice,
    required ItemType type,
    required TaxConfig config,
  }) {
    final P = inclusivePrice;

    if (type == ItemType.regular) {
      final divisor = Decimal.one + config.vatRate;

      // IMPORTANT: Decimal division returns Rational in the decimal package.
      final base = (P / divisor).toDecimal(scaleOnInfinitePrecision: 12);
      final vat = P - base;

      return TaxBreakdown(
        inclusive: Money.round2(P),
        base: Money.round2(base),
        excise: Decimal.zero,
        vat: Money.round2(vat),
      );
    }

    // Tobacco:
    // base = P / multiplier
    // excise = base * exciseRate
    // vat = (base + excise) * vatRate
    final base = (P / config.tobaccoMultiplier).toDecimal(scaleOnInfinitePrecision: 12);
    final excise = base * config.tobaccoExciseRate;
    final vat = (base + excise) * config.vatRate;

    return TaxBreakdown(
      inclusive: Money.round2(P),
      base: Money.round2(base),
      excise: Money.round2(excise),
      vat: Money.round2(vat),
    );
  }
}
