import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                  ProductDetailScreen.routname,
                  arguments: product.id),
              child: Hero(
                tag: product.id!,
                child: FadeInImage(
                  placeholder:
                      AssetImage('assets/images/product-placeholder.png'),
                  image: NetworkImage(product.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black87,
              leading: Consumer<Product>(
                builder: (context, value, child) => IconButton(
                  icon: value.isFavorite!
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: () {
                    product.toggleFavoriteStatus(auth.token!, auth.userID!);
                  },
                ),
              ),
              title: Text(
                product.title!,
                textAlign: TextAlign.center,
              ),
              trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  cart.addItem(product.id!, product.title!, product.price!);
                  Scaffold.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text("Added To Card!"),
                    action: SnackBarAction(
                      label: "Undo!",
                      onPressed: () => cart.removeSingleItem(product.id!),
                    ),
                  ));
                },
              ),
            )));
  }
}
