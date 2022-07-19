import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static String routname = "/order-screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (_, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.hasError) {
            return Center(
              child: Text("An Error occurred"),
            );
          } else
            return Consumer<Orders>(
              builder: (ctx, ordervalue, child) => ListView.builder(
                itemCount: ordervalue.orders.length,
                itemBuilder: (BuildContext context, int index) {
                  return OrderItem(ordervalue.orders[index]);
                },
              ),
            );
        },
      ),
    );
  }
}
