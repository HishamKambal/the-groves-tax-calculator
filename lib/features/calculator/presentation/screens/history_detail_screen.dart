import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/money.dart';
import '../providers/cart_provider.dart';
import '../widgets/breakdown_pie_chart.dart';
import '../widgets/cart_item_tile.dart';

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final entry = history.where((e) => e.id == entryId).cast().firstOrNull;

    if (entry == null) {
      return const Scaffold(
        body: Center(child: Text('History entry not found.')),
      );
    }

    Decimal sumInclusive = Decimal.zero;
    Decimal sumBase = Decimal.zero;
    Decimal sumExcise = Decimal.zero;
    Decimal sumVat = Decimal.zero;

    for (final it in entry.items) {
      sumInclusive += it.inclusive;
      sumBase += it.base;
      sumExcise += it.excise;
      sumVat += it.vat;
    }

    sumInclusive = Money.round2(sumInclusive);
    sumBase = Money.round2(sumBase);
    sumExcise = Money.round2(sumExcise);
    sumVat = Money.round2(sumVat);

    return Scaffold(
      appBar: AppBar(title: const Text('History Details')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Config used', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Currency: ${entry.currencyCode}'),
                  Text('VAT: ${(double.parse(entry.vatRate.toString()) * 100).toStringAsFixed(2)}%'),
                  Text('Excise: ${(double.parse(entry.exciseRate.toString()) * 100).toStringAsFixed(2)}% of base'),
                  Text('Tobacco multiplier: ${entry.tobaccoMultiplier.toString()}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Totals', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _row('Inclusive', Money.format(sumInclusive, currencyCode: entry.currencyCode)),
                  _row('Base', Money.format(sumBase, currencyCode: entry.currencyCode)),
                  _row('Excise', Money.format(sumExcise, currencyCode: entry.currencyCode)),
                  _row('VAT', Money.format(sumVat, currencyCode: entry.currencyCode)),
                  const Divider(),
                  _row('Total Tax', Money.format(sumExcise + sumVat, currencyCode: entry.currencyCode)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          BreakdownPieChart(
            base: sumBase,
            excise: sumExcise,
            vat: sumVat,
            currencyCode: entry.currencyCode,
          ),

          const SizedBox(height: 12),
          Text('Items (${entry.items.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...entry.items.map((it) => CartItemTile(item: it, onDelete: null)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
