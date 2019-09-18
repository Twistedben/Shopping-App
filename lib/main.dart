import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/orders_screen.dart';
import './providers/orders.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // An alternative syntax to using value, you can use a builder instead, seen below commented out. The difference is for value, use it on a list or grid. You make sure the provider works even if data changes for the widget, for builder it doesn't. Providing data on single list or grid items, .value is better. :
    // return ChangeNotifierProvider.(builder: (_) => Products(), )
    // builder: (_) => Products(), // provides an instance of this class to all child widgets, so they can listen and be rebuilt
    return MultiProvider(
      // MultiProvider allows multiple providers to be added, like Products and Cart in this case
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        // Below - We added authToken and constructor to products so to get the token from Auth to Products we use ProxyProvider (requires the class to grab from, Auth, and the one it's affecting, Products, as arguments), which has a builder
        // and in that builder has a dynamic value that relies on a previous provider (in this case, auth). So now that builder and class has access to auth as that dynamic value, so we can use it.
        // Now this will be rebuilt when auth changes. The third argument in the builder is the previous State of Products
        ChangeNotifierProxyProvider<Auth, Products>(
          builder: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      // Below - Use Consumer of auth to rebuild this materialApp tree when authentication happens. So when notifyListens is called, this is triggered.
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          // Below - We check auth property passed by consumer, calling isAuth getter from auth.dart. If there is a token, therefor logged in, then show productsoverviewscreen, otherwise show authscreen so they can log in
          // If user logs in manually, show Products screen, if they have local storage loging data, try that to login whileshowing SplashScreen, otherwise show AuthScreen login.
          home: auth.isAuth
              ? ProductsOverviewScreen()
              // We use a future builder to also check if the tryAutoLogin would work using local storage data to login
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
