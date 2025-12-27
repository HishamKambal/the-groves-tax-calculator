import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/money.dart';
import '../../domain/models/cart_item.dart';

class ItemInputCard extends StatefulWidget {
  const ItemInputCard({
    super.key,
    required this.currencyCode,
    required this.onAdd,
  });

  final String currencyCode;
  final Future<void> Function(Decimal inclusivePrice, ItemType type) onAdd;

  @override
  State<ItemInputCard> createState() => _ItemInputCardState();
}

class _ItemInputCardState extends State<ItemInputCard> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  ItemType _type = ItemType.regular;

  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl.addListener(_recalcCanSubmit);
  }

  @override
  void dispose() {
    _priceCtrl.removeListener(_recalcCanSubmit);
    _priceCtrl.dispose();
    super.dispose();
  }

  void _recalcCanSubmit() {
    final d = Money.parseToDecimal(_priceCtrl.text);
    final next = d != null && d > Decimal.zero;

    if (next != _canSubmit) {
      setState(() => _canSubmit = next);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = Money.parseToDecimal(_priceCtrl.text)!;

    // Haptic: success tap
    HapticFeedback.lightImpact();

    await widget.onAdd(Money.round2(price), _type);

    _priceCtrl.clear();

    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Add Item', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: InputDecoration(
                  labelText: 'Inclusive price (${widget.currencyCode})',
                  hintText: 'e.g. 115.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) async {
                  if (_canSubmit) {
                    await _submit();
                  }
                },
                validator: (v) {
                  final d = Money.parseToDecimal(v ?? '');
                  if (d == null) return 'Enter a valid number.';
                  if (d <= Decimal.zero) return 'Price must be greater than 0.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ItemType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Item type'),
                items: const [
                  DropdownMenuItem(value: ItemType.regular, child: Text('Regular (15% VAT)')),
                  DropdownMenuItem(value: ItemType.tobacco, child: Text('Tobacco (Excise + VAT)')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  HapticFeedback.selectionClick();
                  setState(() => _type = v);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canSubmit ? () async => _submit() : null,
                  child: const Text('Add Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
