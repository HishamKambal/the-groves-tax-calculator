import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../calculator/data/local/settings_local_store.dart';
import '../../domain/services/tax_calculator.dart';

class GrovesSettings {
  final Decimal vatRate;
  final Decimal tobaccoExciseRate;
  final Decimal tobaccoMultiplier;
  final String currencyCode;
  final ThemeMode themeMode;

  const GrovesSettings({
    required this.vatRate,
    required this.tobaccoExciseRate,
    required this.tobaccoMultiplier,
    required this.currencyCode,
    required this.themeMode,
  });

  GrovesSettings copyWith({
    Decimal? vatRate,
    Decimal? tobaccoExciseRate,
    Decimal? tobaccoMultiplier,
    String? currencyCode,
    ThemeMode? themeMode,
  }) {
    return GrovesSettings(
      vatRate: vatRate ?? this.vatRate,
      tobaccoExciseRate: tobaccoExciseRate ?? this.tobaccoExciseRate,
      tobaccoMultiplier: tobaccoMultiplier ?? this.tobaccoMultiplier,
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  TaxConfig toTaxConfig() {
    return TaxConfig(
      vatRate: vatRate,
      tobaccoExciseRate: tobaccoExciseRate,
      tobaccoMultiplier: tobaccoMultiplier,
      currencyCode: currencyCode,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, GrovesSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<GrovesSettings> {
  static const _kVat = 'vatRate';
  static const _kExcise = 'tobaccoExciseRate';
  static const _kMultiplier = 'tobaccoMultiplier';
  static const _kCurrency = 'currencyCode';
  static const _kTheme = 'themeMode';

  @override
  GrovesSettings build() {
    final box = SettingsLocalStore.box;

    final defaultState = GrovesSettings(
      vatRate: Decimal.parse(AppConstants.defaultVatRate.toString()),
      tobaccoExciseRate: Decimal.parse(AppConstants.defaultTobaccoExciseRate.toString()),
      tobaccoMultiplier: Decimal.parse(AppConstants.defaultTobaccoMultiplier.toString()),
      currencyCode: AppConstants.currencySar,
      themeMode: ThemeMode.system,
    );

    final vat = box.get(_kVat);
    final excise = box.get(_kExcise);
    final mult = box.get(_kMultiplier);
    final cur = box.get(_kCurrency);
    final theme = box.get(_kTheme);

    return defaultState.copyWith(
      vatRate: vat is String ? Decimal.parse(vat) : defaultState.vatRate,
      tobaccoExciseRate: excise is String ? Decimal.parse(excise) : defaultState.tobaccoExciseRate,
      tobaccoMultiplier: mult is String ? Decimal.parse(mult) : defaultState.tobaccoMultiplier,
      currencyCode: cur is String ? cur : defaultState.currencyCode,
      themeMode: theme is int ? ThemeMode.values[theme] : defaultState.themeMode,
    );
  }

  Future<void> setVatRate(Decimal v) async {
    state = state.copyWith(vatRate: v);
    await _persist();
  }

  Future<void> setExciseRate(Decimal v) async {
    state = state.copyWith(tobaccoExciseRate: v);
    await _persist();
  }

  Future<void> setMultiplier(Decimal v) async {
    state = state.copyWith(tobaccoMultiplier: v);
    await _persist();
  }

  Future<void> setCurrency(String code) async {
    state = state.copyWith(currencyCode: code);
    await _persist();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> _persist() async {
    final box = SettingsLocalStore.box;
    await box.put(_kVat, state.vatRate.toString());
    await box.put(_kExcise, state.tobaccoExciseRate.toString());
    await box.put(_kMultiplier, state.tobaccoMultiplier.toString());
    await box.put(_kCurrency, state.currencyCode);
    await box.put(_kTheme, state.themeMode.index);
  }
}
