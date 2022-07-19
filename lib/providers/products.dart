import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /* Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
   */
  ];
  String? authToken;
  String? userId;
  getData(String authToken, String userId, List<Product> products) {
    this._items = products;
    this.userId = userId;
    this.authToken = authToken;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite == true).toList();
  }

  Product findItemById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filteredString =
        !filterByUser ? "" : "orderBy='creatorId'&equalTo='$userId'";
    var url =
        "https://shoper-4b6ea-default-rtdb.firebaseio.com/products.json?auth=$authToken$filteredString";
    try {
      final res = await http.get(url);
      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data == null) return;
      url =
          "https://shoper-4b6ea-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken";
      final favRes = await http.get(url);
      final favData = json.decode(favRes.body);
      final List<Product> loadedProducts = [];

      data.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            description: prodData['description'],
            price: prodData['price'],
            title: prodData['title'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favData == null ? false : favData[prodId] == null ?? false,
          ),
        );
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> updateProduct(String id, Product newproduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url =
          "https://shoper-4b6ea-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
      await http.patch(url,
          body: json.encode({
            'title': newproduct.title,
            'description': newproduct.description,
            'imageUrl': newproduct.imageUrl,
            'price': newproduct.price,
          }));
      _items[prodIndex] = newproduct;
      notifyListeners();
    } else {}
  }

  Future<void> addProducts(Product product) async {
    final url =
        "https://shoper-4b6ea-default-rtdb.firebaseio.com/products.json?auth=$authToken";

    try {
      final res = await http.post(url,
          body: json.encode({
            'created': userId,
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteProducts(String id) async {
    final url =
        "https://shoper-4b6ea-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";

    try {
      final existingProductIndex =
          _items.indexWhere((element) => element.id == id);
      Product? existingProductItem = _items[existingProductIndex];
      _items.removeAt(existingProductIndex);
      notifyListeners();
      final res = await http.delete(url);
      if (res.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProductItem);
        notifyListeners();
        throw HttpException("Coudn't Delete This Product");
      }
      existingProductItem = null;
    } catch (e) {}
  }
}
