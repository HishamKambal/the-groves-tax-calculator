import '../../domain/models/cart_item.dart';
import '../local/cart_local_store.dart';

class CartRepository {
  List<CartItem> load() => CartLocalStore.loadCart();

  Future<void> save(List<CartItem> items) => CartLocalStore.saveCart(items);

  Future<void> clear() => CartLocalStore.clear();
}
