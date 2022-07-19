import 'package:flutter/material.dart';

class CartItem {
  final String? id;
  final String? title;
  final int? quantity;
  final double? price;
  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.quantity! * value.price!;
    });
    return total;
  }

  void addItem(String prodid, String title, double price) {
    if (_items.containsKey(prodid)) {
      _items.update(
          prodid,
          (productItem) => CartItem(
                id: productItem.id,
                price: productItem.price,
                quantity: productItem.quantity! + 1,
                title: productItem.title,
              ));
      notifyListeners();
    } else {
      _items.putIfAbsent(
          prodid,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
      notifyListeners();
    }
  }

  void removeItem(String prodid) {
    _items.remove(prodid);
    notifyListeners();
  }

  void removeSingleItem(String prodid) {
    if (!_items.containsKey(prodid)) return;
    if (_items[prodid]!.quantity! > 1) {
      _items.update(
          prodid,
          (value) => CartItem(
              id: value.id,
              title: value.title,
              quantity: value.quantity! - 1,
              price: value.price));
    } else {
      _items.remove(prodid);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
