import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/products.dart';
import './providers/auth.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/order_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/user_products_screen.dart';
import './screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders(),
          update: (ctx, authvalue, previousOrders) => previousOrders
            ..getData(authvalue.token!, authvalue.userID!,
                previousOrders == null ? [] : previousOrders.orders),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products(),
          update: (ctx, authvalue, previousProducts) => previousProducts
            ..getData(authvalue.token!, authvalue.userID!,
                previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, value, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: Provider.of<Auth>(context).isAuth
              ? ProductOverViewScreen()
              : FutureBuilder(

                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductOverViewScreen.routename: (_) => ProductOverViewScreen(),
            ProductDetailScreen.routname: (_) => ProductDetailScreen(),
            CartScreen.routname: (_) => CartScreen(),
            OrderScreen.routname: (_) => OrderScreen(),
            EditProductScreen.routname: (_) => EditProductScreen(),
            UserProductScreen.routname: (_) => UserProductScreen(),
          },
        ),
      ),
    );
  }
}
