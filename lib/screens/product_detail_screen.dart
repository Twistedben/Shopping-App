import 'package:flutter/material.dart';

import '../providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;

  // ProductDetailScreen(this.title);
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments
        as String; // Gives us the ID provided by NAvigator.pushedName on product_item.dart's GestureDetector onpress.
    // Provider.of<Products>(context) gives us access to all products so we can tap into that
    // Move as much logic as possible into the class. So we move the find product logic (firstWhere) into the class Products as a method.
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false, // listen false will NOT rebuild the widget each time when notifyListeners is called. Since this is a show page, you don't need to update.
    ).findById(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
    );
  }
}
