import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/breakdown_pie_chart.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/item_input_card.dart';
import '../widgets/totals_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Groves'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ItemInputCard(
              currencyCode: settings.currencyCode,
              onAdd: (inclusive, type) async {
                HapticFeedback.lightImpact();
                await ref.read(cartProvider.notifier).addItem(
                      inclusivePrice: inclusive,
                      type: type,
                    );
              },
            ),
            const SizedBox(height: 12),

            if (items.isNotEmpty) ...[
              TotalsCard(
                currencyCode: settings.currencyCode,
                totalsInclusive: totals.inclusive,
                totalsBase: totals.base,
                totalsExcise: totals.excise,
                totalsVat: totals.vat,
                onSaveHistory: () async {
                  HapticFeedback.mediumImpact();
                  await ref.read(cartProvider.notifier).saveSnapshotToHistory();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Saved to history.'),
                      action: SnackBarAction(
                        label: 'View',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          );
                        },
                      ),
                    ),
                  );
                },
                onClear: () async {
                  HapticFeedback.heavyImpact();
                  await ref.read(cartProvider.notifier).clear();
                },
              ),
              const SizedBox(height: 12),
              BreakdownPieChart(
                base: totals.base,
                excise: totals.excise,
                vat: totals.vat,
                currencyCode: settings.currencyCode,
              ),
              const SizedBox(height: 12),
            ],

            Text('Items (${items.length})', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No items yet. Add an item to begin.')),
              )
            else
              ...items.map(
                (it) => CartItemTile(
                  item: it,
                  onDelete: () async {
                    HapticFeedback.lightImpact();
                    await ref.read(cartProvider.notifier).removeItem(it.id);
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
