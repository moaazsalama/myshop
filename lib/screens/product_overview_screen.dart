import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

class ProductOverViewScreen extends StatefulWidget {
  static String routename = "Product-overview";
  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

enum FilterOption { Favorites, All }

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  // ignore: unused_field
  bool _isLoading = false;
  // ignore: unused_field
  bool _shwoOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyShop"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOption newvalue) {
              setState(() {
                if (newvalue == FilterOption.Favorites)
                  _shwoOnlyFavorites = true;
                else
                  _shwoOnlyFavorites = false;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOption.Favorites,
              ),
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterOption.All,
              ),
            ],
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routname),
            ),
            builder: (context, value, child) =>
                Badge(child: child, value: value.itemCount.toString()),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_shwoOnlyFavorites),
    );
  }
}
