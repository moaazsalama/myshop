import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';

class OrderItem {
  final String? id;
  final double? amount;
  final DateTime? dateTime;
  final List<CartItem>? products;
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;
  getData(String authToken, String userId, List<OrderItem> orders) {
    this._orders = orders;
    this.userId = userId;
    this.authToken = authToken;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    var url =
        "https://shoper-4b6ea-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    try {
      final res = await http.get(url);
      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data == null) return;
      final List<OrderItem> loadedOrders = [];
      data.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
              id: orderId,
              amount: orderData['amount'],
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>)
                  .map((e) => CartItem(
                      id: e['id'],
                      title: e['title'],
                      quantity: e['quantity'],
                      price: e['price']))
                  .toList()),
        );
      });
      _orders = loadedOrders.reversed.toList();
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        "https://shoper-4b6ea-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";

    try {
      final timestamp = DateTime.now();
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProduct
                .map((e) => {
                      'id': e.id,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price
                    })
                .toList(),
          }));
      orders.insert(
          0,
          OrderItem(
              id: json.decode(res.body)['name'],
              amount: total,
              dateTime: timestamp,
              products: cartProduct));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
