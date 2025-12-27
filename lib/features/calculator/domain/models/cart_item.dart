import 'package:decimal/decimal.dart';

enum ItemType { regular, tobacco }

class CartItem {
  final String id;
  final ItemType type;

  /// Stored values are already rounded to 2 decimals for UI-total consistency.
  final Decimal inclusive;
  final Decimal base;
  final Decimal excise;
  final Decimal vat;

  final String currencyCode;
  final DateTime createdAt;

  /// Snapshot of config used at the time this item was created (important for history integrity).
  final Decimal vatRate;
  final Decimal exciseRate;
  final Decimal tobaccoMultiplier;

  CartItem({
    required this.id,
    required this.type,
    required this.inclusive,
    required this.base,
    required this.excise,
    required this.vat,
    required this.currencyCode,
    required this.createdAt,
    required this.vatRate,
    required this.exciseRate,
    required this.tobaccoMultiplier,
  });

  Decimal get totalTax => excise + vat;
}
