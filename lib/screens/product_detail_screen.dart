import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;

  // ProductDetailScreen(this.title);
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String; // Gives us the ID provided by NAvigator.pushedName on product_item.dart's GestureDetector onpress.
    
    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),
    );
  }
}
