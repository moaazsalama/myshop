import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static String routname = "/user-screen";
  @override
  Widget build(BuildContext context) {
    Future<void> _refeshProducts(BuildContext context) async {
      await Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts(true);
    }

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Your Products"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routname);
              })
        ],
      ),
      body: FutureBuilder(
        future: _refeshProducts(context),
        builder: (ctx, AsyncSnapshot snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    child: Consumer<Products>(
                      builder: (context, value, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: value.items.length,
                          itemBuilder: (_, int index) => Column(
                            children: [
                              UserProductItem(value.items[index]),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onRefresh: () => _refeshProducts(ctx),
                  ),
      ),
    );
  }
}
