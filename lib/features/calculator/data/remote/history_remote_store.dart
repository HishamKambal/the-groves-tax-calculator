import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';

import '../../domain/models/cart_item.dart';
import '../repositories/history_repository.dart'; // HistoryEntry

class HistoryRemoteStore {
  HistoryRemoteStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ✅ Must match Firestore rules path: /users/{uid}/histories/{historyId}
  CollectionReference<Map<String, dynamic>> _historyCol(String uid) {
    return _db.collection('users').doc(uid).collection('histories');
  }

  Future<void> upsertEntry({
    required String uid,
    required HistoryEntry entry,
  }) async {
    final doc = _historyCol(uid).doc(entry.id);
    await doc.set(_entryToMap(entry), SetOptions(merge: true));
  }

  Future<List<HistoryEntry>> fetchAll({
    required String uid,
  }) async {
    final snap =
        await _historyCol(uid).orderBy('createdAt', descending: true).get();

    return snap.docs.map((d) => _entryFromMap(d.id, d.data())).toList();
  }

  Future<void> deleteAll({required String uid}) async {
    final snap = await _historyCol(uid).get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  // -------------------------
  // Serialization helpers
  // -------------------------

  Map<String, dynamic> _entryToMap(HistoryEntry e) {
    return <String, dynamic>{
      // ✅ Required by rules
      'id': e.id,
      'createdAt': Timestamp.fromDate(e.createdAt),
      'currencyCode': e.currencyCode,
      // Store Decimal as strings (safe + consistent)
      'vatRate': e.vatRate.toString(),
      'exciseRate': e.exciseRate.toString(),
      'tobaccoMultiplier': e.tobaccoMultiplier.toString(),
      'items': e.items.map(_itemToMap).toList(growable: false),
    };
  }

  HistoryEntry _entryFromMap(String docId, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    final createdAt = ts is Timestamp ? ts.toDate() : DateTime.now();

    final itemsRaw = m['items'];
    final items = <CartItem>[];

    if (itemsRaw is List) {
      for (final x in itemsRaw) {
        if (x is Map) {
          items.add(_itemFromMap(Map<String, dynamic>.from(x)));
        }
      }
    }

    // Prefer stored id if present; otherwise fallback to docId
    final id = (m['id'] as String?)?.trim();
    final safeId = (id != null && id.isNotEmpty) ? id : docId;

    return HistoryEntry(
      id: safeId,
      createdAt: createdAt,
      currencyCode: (m['currencyCode'] as String?) ?? 'SAR',
      vatRate: Decimal.parse((m['vatRate'] ?? '0.15').toString()),
      exciseRate: Decimal.parse((m['exciseRate'] ?? '1.00').toString()),
      tobaccoMultiplier:
          Decimal.parse((m['tobaccoMultiplier'] ?? '2.30').toString()),
      items: items,
    );
  }

  Map<String, dynamic> _itemToMap(CartItem it) {
    return <String, dynamic>{
      'id': it.id,
      'type': it.type.name, // "regular" / "tobacco"
      'inclusive': it.inclusive.toString(),
      'base': it.base.toString(),
      'excise': it.excise.toString(),
      'vat': it.vat.toString(),
      'currencyCode': it.currencyCode,
      'createdAt': Timestamp.fromDate(it.createdAt),
      'vatRate': it.vatRate.toString(),
      'exciseRate': it.exciseRate.toString(),
      'tobaccoMultiplier': it.tobaccoMultiplier.toString(),
    };
  }

  CartItem _itemFromMap(Map<String, dynamic> m) {
    final typeStr = (m['type'] as String?) ?? ItemType.regular.name;
    final type =
        typeStr == ItemType.tobacco.name ? ItemType.tobacco : ItemType.regular;

    final createdAtRaw = m['createdAt'];
    final createdAt =
        createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now();

    return CartItem(
      id: (m['id'] as String?) ?? '',
      type: type,
      inclusive: Decimal.parse((m['inclusive'] ?? '0').toString()),
      base: Decimal.parse((m['base'] ?? '0').toString()),
      excise: Decimal.parse((m['excise'] ?? '0').toString()),
      vat: Decimal.parse((m['vat'] ?? '0').toString()),
      currencyCode: (m['currencyCode'] as String?) ?? 'SAR',
      createdAt: createdAt,
      vatRate: Decimal.parse((m['vatRate'] ?? '0.15').toString()),
      exciseRate: Decimal.parse((m['exciseRate'] ?? '1.00').toString()),
      tobaccoMultiplier:
          Decimal.parse((m['tobaccoMultiplier'] ?? '2.30').toString()),
    );
  }
}
