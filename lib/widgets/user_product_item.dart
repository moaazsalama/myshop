import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  String? productid;
  String? title;
  String? imageUrl;
  UserProductItem(Product product) {
    this.productid = product.id;
    this.title = product.title;
    this.imageUrl = product.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title.toString()),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl!),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.routname,
                      arguments: productid);
                }),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProducts(productid!);
                } catch (e) {
                  scaffold.showSnackBar(SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text(
                      "Deleting Failed",
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
