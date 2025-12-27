import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/remote/history_remote_store.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/services/tax_calculator.dart';
import 'settings_provider.dart';

// Providers
final cartRepoProvider = Provider<CartRepository>((ref) => CartRepository());
final historyRepoProvider = Provider<HistoryRepository>((ref) => HistoryRepository());
final historyRemoteProvider = Provider<HistoryRemoteStore>((ref) => HistoryRemoteStore());

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(HistoryNotifier.new);

class CartTotals {
  final Decimal inclusive;
  final Decimal base;
  final Decimal excise;
  final Decimal vat;

  CartTotals({
    required this.inclusive,
    required this.base,
    required this.excise,
    required this.vat,
  });

  Decimal get totalTax => excise + vat;
}

final cartTotalsProvider = Provider<CartTotals>((ref) {
  final items = ref.watch(cartProvider);

  Decimal sumInclusive = Decimal.zero;
  Decimal sumBase = Decimal.zero;
  Decimal sumExcise = Decimal.zero;
  Decimal sumVat = Decimal.zero;

  for (final it in items) {
    sumInclusive += it.inclusive;
    sumBase += it.base;
    sumExcise += it.excise;
    sumVat += it.vat;
  }

  return CartTotals(
    inclusive: Money.round2(sumInclusive),
    base: Money.round2(sumBase),
    excise: Money.round2(sumExcise),
    vat: Money.round2(sumVat),
  );
});

class CartNotifier extends Notifier<List<CartItem>> {
  final _calc = const TaxCalculator();
  final _uuid = const Uuid();

  @override
  List<CartItem> build() {
    return ref.read(cartRepoProvider).load();
  }

  Future<void> addItem({
    required Decimal inclusivePrice,
    required ItemType type,
  }) async {
    final settings = ref.read(settingsProvider);
    final config = settings.toTaxConfig();

    final breakdown = _calc.calculate(
      inclusivePrice: inclusivePrice,
      type: type,
      config: config,
    );

    final item = CartItem(
      id: _uuid.v4(),
      type: type,
      inclusive: breakdown.inclusive,
      base: breakdown.base,
      excise: breakdown.excise,
      vat: breakdown.vat,
      currencyCode: config.currencyCode,
      createdAt: DateTime.now(),
      vatRate: config.vatRate,
      exciseRate: config.tobaccoExciseRate,
      tobaccoMultiplier: config.tobaccoMultiplier,
    );

    state = [...state, item];
    await ref.read(cartRepoProvider).save(state);
  }

  Future<void> removeItem(String id) async {
    state = state.where((e) => e.id != id).toList(growable: false);
    await ref.read(cartRepoProvider).save(state);
  }

  Future<void> clear() async {
    state = <CartItem>[];
    await ref.read(cartRepoProvider).clear();
  }

  Future<void> saveSnapshotToHistory() async {
    if (state.isEmpty) return;

    final settings = ref.read(settingsProvider);

    final entry = HistoryEntry(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      currencyCode: settings.currencyCode,
      vatRate: settings.vatRate,
      exciseRate: settings.tobaccoExciseRate,
      tobaccoMultiplier: settings.tobaccoMultiplier,
      items: List<CartItem>.from(state),
    );

    await ref.read(historyProvider.notifier).add(entry);
  }
}

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  bool listenerInstalled = false;

  @override
  List<HistoryEntry> build() {
    final local = ref.read(historyRepoProvider).load();

    if (!listenerInstalled) {
      listenerInstalled = true;

      ref.listen(authStateProvider, (prev, next) {
        next.when(
          data: (u) async {
            if (u == null) {
              state = ref.read(historyRepoProvider).load();
            } else {
              await syncFromRemote(uid: u.uid);
            }
          },
          loading: () {},
          error: (_, error) {}, // ✅ FIXED
        );
      });

      final current = ref.read(authStateProvider);
      current.whenData((u) {
        if (u != null) {
          Future.microtask(() => syncFromRemote(uid: u.uid));
        }
      });
    }

    return local;
  }

  Future<void> add(HistoryEntry entry) async {
    state = [entry, ...state];
    await ref.read(historyRepoProvider).save(state);

    final uid = currentUid();
    if (uid != null) {
      await ref.read(historyRemoteProvider).upsertEntry(uid: uid, entry: entry);
    }
  }

  Future<void> clear() async {
    state = const [];
    await ref.read(historyRepoProvider).clear();

    final uid = currentUid();
    if (uid != null) {
      await ref.read(historyRemoteProvider).deleteAll(uid: uid);
    }
  }

  String? currentUid() {
    final authState = ref.read(authStateProvider);
    return authState.maybeWhen(
      data: (u) => u?.uid,
      orElse: () => null,
    );
  }

  Future<void> syncFromRemote({required String uid}) async {
    final remote = await ref.read(historyRemoteProvider).fetchAll(uid: uid);
    state = remote;
    await ref.read(historyRepoProvider).save(remote);
  }
}
