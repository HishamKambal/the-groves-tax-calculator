import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/account_screen.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _vatCtrl;
  late final TextEditingController _exciseCtrl;
  late final TextEditingController _multCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _vatCtrl = TextEditingController(text: s.vatRate.toString());
    _exciseCtrl = TextEditingController(text: s.tobaccoExciseRate.toString());
    _multCtrl = TextEditingController(text: s.tobaccoMultiplier.toString());
  }

  @override
  void dispose() {
    _vatCtrl.dispose();
    _exciseCtrl.dispose();
    _multCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authStateProvider);

    final accountSubtitle = authState.when(
      data: (u) => u == null ? 'Not signed in' : 'Signed in as ${u.email ?? 'user'}',
      loading: () => 'Checking sign-in…',
      error: (_, _) => 'Auth unavailable',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Account (new, minimal)
          Card(
            child: ListTile(
              title: const Text('Account'),
              subtitle: Text(accountSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: settings.currencyCode,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: const [
                      DropdownMenuItem(value: AppConstants.currencySar, child: Text('SAR')),
                      DropdownMenuItem(value: AppConstants.currencyUsd, child: Text('USD')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await ref.read(settingsProvider.notifier).setCurrency(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ThemeMode>(
                    initialValue: settings.themeMode,
                    decoration: const InputDecoration(labelText: 'Theme'),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await ref.read(settingsProvider.notifier).setThemeMode(v);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    controller: _vatCtrl,
                    decoration: const InputDecoration(
                      labelText: 'VAT rate (e.g. 0.15 for 15%)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _exciseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tobacco excise rate (e.g. 1.00 for 100% of base)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _multCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tobacco multiplier (default 2.30)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final vat = Money.parseToDecimal(_vatCtrl.text);
                        final excise = Money.parseToDecimal(_exciseCtrl.text);
                        final mult = Money.parseToDecimal(_multCtrl.text);

                        if (vat == null || excise == null || mult == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid numeric values.')),
                          );
                          return;
                        }
                        if (vat <= Decimal.zero || vat >= Decimal.one) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('VAT rate should be between 0 and 1 (e.g., 0.15).')),
                          );
                          return;
                        }
                        if (excise < Decimal.zero) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Excise rate cannot be negative.')),
                          );
                          return;
                        }
                        if (mult <= Decimal.zero) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Multiplier must be > 0.')),
                          );
                          return;
                        }

                        await ref.read(settingsProvider.notifier).setVatRate(vat);
                        await ref.read(settingsProvider.notifier).setExciseRate(excise);
                        await ref.read(settingsProvider.notifier).setMultiplier(mult);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings saved.')),
                          );
                        }
                      },
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
