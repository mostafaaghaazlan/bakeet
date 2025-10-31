import 'package:bloc/bloc.dart';
part 'cart_state.dart';

class CartItem {
  final String productId;
  final String vendorId;
  int qty;
  final double unitPrice;

  CartItem({
    required this.productId,
    required this.vendorId,
    required this.qty,
    required this.unitPrice,
  });
}

class CartCubit extends Cubit<CartState> {
  final List<CartItem> _items = [];

  CartCubit() : super(CartInitial());

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem(CartItem item) {
    final existing = _items.indexWhere((i) => i.productId == item.productId);
    if (existing >= 0) {
      _items[existing].qty += item.qty;
    } else {
      _items.add(item);
    }
    emit(CartUpdated(items));
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.productId == productId);
    emit(CartUpdated(items));
  }

  void updateQuantity(String productId, int qty) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      _items[idx].qty = qty;
      if (_items[idx].qty <= 0) {
        _items.removeAt(idx);
      }
      emit(CartUpdated(items));
    }
  }

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.unitPrice * i.qty);

  void clear() {
    _items.clear();
    emit(CartUpdated(items));
  }
}
