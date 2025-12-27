import 'package:hive/hive.dart';

import '../../domain/models/cart_item.dart';

class CartLocalStore {
  static const String boxName = 'groves_cart';
  static Box<dynamic>? _box;

  static Future<void> openBox() async {
    _box ??= await Hive.openBox<dynamic>(boxName);
  }

  static Box<dynamic> get box {
    final b = _box;
    if (b == null) {
      throw StateError('Cart box not opened.');
    }
    return b;
  }

  static const String cartKey = 'cart_items';

  static List<CartItem> loadCart() {
    final raw = box.get(cartKey);
    if (raw is List) {
      return raw.cast<CartItem>();
    }
    return <CartItem>[];
  }

  static Future<void> saveCart(List<CartItem> items) async {
    await box.put(cartKey, items);
  }

  static Future<void> clear() async {
    await box.delete(cartKey);
  }
}
