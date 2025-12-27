import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';

class BreakdownPieChart extends StatelessWidget {
  const BreakdownPieChart({
    super.key,
    required this.base,
    required this.excise,
    required this.vat,
    required this.currencyCode,
  });

  final Decimal base;
  final Decimal excise;
  final Decimal vat;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final baseD = base.toDouble();
    final exciseD = excise.toDouble();
    final vatD = vat.toDouble();

    final total = baseD + exciseD + vatD;
    if (total <= 0) return const SizedBox.shrink();

    // Groves palette (greenish)
    final baseColor = const Color(0xFF2E7D32); // deep green
    final exciseColor = const Color(0xFF1B5E20); // darker green
    final vatColor = const Color(0xFF66BB6A); // lighter green

    final titleStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

    final border = BorderSide(
      color: Colors.black.withValues(alpha: 0.25),
      width: 1,
    );

    final sections = <PieChartSectionData>[
      if (baseD > 0)
        PieChartSectionData(
          value: baseD,
          title: 'Base',
          radius: 52,
          color: baseColor, // ✅ explicit color
          borderSide: border,
          titleStyle: titleStyle,
        ),
      if (exciseD > 0)
        PieChartSectionData(
          value: exciseD,
          title: 'Excise',
          radius: 52,
          color: exciseColor, // ✅ explicit color
          borderSide: border,
          titleStyle: titleStyle,
        ),
      if (vatD > 0)
        PieChartSectionData(
          value: vatD,
          title: 'VAT',
          radius: 52,
          color: vatColor, // ✅ explicit color
          borderSide: border,
          titleStyle: titleStyle,
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 42,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(enabled: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _legendRow('Base', Money.format(base, currencyCode: currencyCode), baseColor),
            _legendRow('Excise', Money.format(excise, currencyCode: currencyCode), exciseColor),
            _legendRow('VAT', Money.format(vat, currencyCode: currencyCode), vatColor),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(String label, String value, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
