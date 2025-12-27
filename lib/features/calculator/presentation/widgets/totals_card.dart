import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';

class TotalsCard extends StatelessWidget {
  const TotalsCard({
    super.key,
    required this.currencyCode,
    required this.totalsInclusive,
    required this.totalsBase,
    required this.totalsExcise,
    required this.totalsVat,
    required this.onSaveHistory,
    required this.onClear,
  });

  final String currencyCode;
  final Decimal totalsInclusive;
  final Decimal totalsBase;
  final Decimal totalsExcise;
  final Decimal totalsVat;

  final Future<void> Function() onSaveHistory;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    final totalTax = totalsExcise + totalsVat;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Grand totals', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () async => onSaveHistory(),
                  child: const Text('Save to History'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _row('Total inclusive', Money.format(totalsInclusive, currencyCode: currencyCode)),
            _row('Total base', Money.format(totalsBase, currencyCode: currencyCode)),
            _row('Total excise', Money.format(totalsExcise, currencyCode: currencyCode)),
            _row('Total VAT', Money.format(totalsVat, currencyCode: currencyCode)),
            const Divider(),
            _row('Total tax', Money.format(totalTax, currencyCode: currencyCode), bold: true),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async => onClear(),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Clear cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
