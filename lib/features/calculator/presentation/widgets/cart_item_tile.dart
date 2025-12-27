import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';
import '../../domain/models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final CartItem item;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final typeLabel = item.type == ItemType.regular ? 'Regular' : 'Tobacco';

    return Card(
      child: ListTile(
        title: Text('$typeLabel • ${Money.format(item.inclusive, currencyCode: item.currencyCode)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            _line('Base', Money.format(item.base, currencyCode: item.currencyCode)),
            _line('Excise', Money.format(item.excise, currencyCode: item.currencyCode)),
            _line('VAT', Money.format(item.vat, currencyCode: item.currencyCode)),
            const Divider(height: 16),
            _line('Total Tax', Money.format(item.totalTax, currencyCode: item.currencyCode), bold: true),
          ],
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                tooltip: 'Delete',
                onPressed: () => onDelete?.call(),
                icon: const Icon(Icons.delete_outline),
              ),
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
        ),
      ],
    );
  }
}
