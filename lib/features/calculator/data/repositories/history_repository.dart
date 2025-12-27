import 'package:decimal/decimal.dart';

import '../../domain/models/cart_item.dart';
import '../local/history_local_store.dart';

class HistoryEntry {
  final String id;
  final DateTime createdAt;

  final String currencyCode;
  final Decimal vatRate;
  final Decimal exciseRate;
  final Decimal tobaccoMultiplier;

  final List<CartItem> items;

  HistoryEntry({
    required this.id,
    required this.createdAt,
    required this.currencyCode,
    required this.vatRate,
    required this.exciseRate,
    required this.tobaccoMultiplier,
    required this.items,
  });
}

class HistoryRepository {
  List<HistoryEntry> load() => HistoryLocalStore.loadHistory();

  Future<void> save(List<HistoryEntry> entries) => HistoryLocalStore.saveHistory(entries);

  Future<void> clear() => HistoryLocalStore.clear();
}
