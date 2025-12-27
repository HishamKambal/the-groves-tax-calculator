import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:groves/features/calculator/domain/models/cart_item.dart';
import 'package:groves/features/calculator/domain/services/tax_calculator.dart';

String _s2(Decimal d) => d.toStringAsFixed(2);

void main() {
  const calc = TaxCalculator();

  test('Regular item reverse calculation', () {
    final config = TaxConfig(
      vatRate: Decimal.parse('0.15'),
      tobaccoExciseRate: Decimal.parse('1.00'),
      tobaccoMultiplier: Decimal.parse('2.30'),
      currencyCode: 'SAR',
    );

    final b = calc.calculate(
      inclusivePrice: Decimal.parse('115.00'),
      type: ItemType.regular,
      config: config,
    );

    // Base = 115 / 1.15 = 100.00, VAT = 15.00
    expect(_s2(b.base), '100.00');
    expect(_s2(b.vat), '15.00');
    expect(_s2(b.excise), '0.00');
    expect(_s2(b.inclusive), '115.00');
  });

  test('Tobacco calculation uses multiplier 2.30', () {
    final config = TaxConfig(
      vatRate: Decimal.parse('0.15'),
      tobaccoExciseRate: Decimal.parse('1.00'),
      tobaccoMultiplier: Decimal.parse('2.30'),
      currencyCode: 'SAR',
    );

    final b = calc.calculate(
      inclusivePrice: Decimal.parse('230.00'),
      type: ItemType.tobacco,
      config: config,
    );

    // base = 230/2.30 = 100.00
    // excise = 100.00
    // vat = (100+100)*0.15 = 30.00
    expect(_s2(b.base), '100.00');
    expect(_s2(b.excise), '100.00');
    expect(_s2(b.vat), '30.00');
    expect(_s2(b.inclusive), '230.00');
  });
}
