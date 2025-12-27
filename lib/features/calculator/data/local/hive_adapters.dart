import 'package:decimal/decimal.dart';
import 'package:hive/hive.dart';

import '../../domain/models/cart_item.dart';
import '../repositories/history_repository.dart';

const int _typeIdCartItem = 10;
const int _typeIdHistoryEntry = 11;
const int _typeIdItemType = 12;

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(_typeIdItemType)) {
    Hive.registerAdapter(ItemTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(_typeIdCartItem)) {
    Hive.registerAdapter(CartItemAdapter());
  }
  if (!Hive.isAdapterRegistered(_typeIdHistoryEntry)) {
    Hive.registerAdapter(HistoryEntryAdapter());
  }
}

class ItemTypeAdapter extends TypeAdapter<ItemType> {
  @override
  int get typeId => _typeIdItemType;

  @override
  ItemType read(BinaryReader reader) {
    final v = reader.readInt();
    return ItemType.values[v];
  }

  @override
  void write(BinaryWriter writer, ItemType obj) {
    writer.writeInt(obj.index);
  }
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  int get typeId => _typeIdCartItem;

  @override
  CartItem read(BinaryReader reader) {
    final id = reader.readString();
    final type = reader.read() as ItemType;

    final inclusiveStr = reader.readString();
    final baseStr = reader.readString();
    final exciseStr = reader.readString();
    final vatStr = reader.readString();

    final currencyCode = reader.readString();
    final createdAtMillis = reader.readInt();

    final vatRateStr = reader.readString();
    final exciseRateStr = reader.readString();
    final multiplierStr = reader.readString();

    return CartItem(
      id: id,
      type: type,
      inclusive: _dec(inclusiveStr),
      base: _dec(baseStr),
      excise: _dec(exciseStr),
      vat: _dec(vatStr),
      currencyCode: currencyCode,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      vatRate: _dec(vatRateStr),
      exciseRate: _dec(exciseRateStr),
      tobaccoMultiplier: _dec(multiplierStr),
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer.writeString(obj.id);
    writer.write(obj.type);

    writer.writeString(obj.inclusive.toString());
    writer.writeString(obj.base.toString());
    writer.writeString(obj.excise.toString());
    writer.writeString(obj.vat.toString());

    writer.writeString(obj.currencyCode);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);

    writer.writeString(obj.vatRate.toString());
    writer.writeString(obj.exciseRate.toString());
    writer.writeString(obj.tobaccoMultiplier.toString());
  }
}

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  int get typeId => _typeIdHistoryEntry;

  @override
  HistoryEntry read(BinaryReader reader) {
    final id = reader.readString();
    final createdAtMillis = reader.readInt();

    final currencyCode = reader.readString();

    final vatRateStr = reader.readString();
    final exciseRateStr = reader.readString();
    final multiplierStr = reader.readString();

    final itemsCount = reader.readInt();
    final items = <CartItem>[];
    for (int i = 0; i < itemsCount; i++) {
      items.add(reader.read() as CartItem);
    }

    return HistoryEntry(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      currencyCode: currencyCode,
      vatRate: _dec(vatRateStr),
      exciseRate: _dec(exciseRateStr),
      tobaccoMultiplier: _dec(multiplierStr),
      items: items,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);

    writer.writeString(obj.currencyCode);
    writer.writeString(obj.vatRate.toString());
    writer.writeString(obj.exciseRate.toString());
    writer.writeString(obj.tobaccoMultiplier.toString());

    writer.writeInt(obj.items.length);
    for (final it in obj.items) {
      writer.write(it);
    }
  }
}

Decimal _dec(String s) => Decimal.parse(s);
