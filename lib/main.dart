import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // An alternative syntax to using value, you can use a builder instead, seen below commented out. The difference is for value, use it on a list or grid. You make sure the provider works even if data changes for the widget, for builder it doesn't. Providing data on single list or grid items, .value is better. :
    // return ChangeNotifierProvider.(builder: (_) => Products(), )
    return ChangeNotifierProvider.value(
      // builder: (_) => Products(), // provides an instance of this class to all child widgets, so they can listen and be rebuilt
      value: Products(),
      child: MaterialApp(
        title: 'Shop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
      ),
      body: Center(
        child: Text('Let\'s build a shop!'),
      ),
    );
  }
}
