import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorites;

  ProductsGrid(this.showFavorites);

  @override
  Widget build(BuildContext context) {
    // The <Products> tells the Provider that a communication channel to the Provided instance of the Products class. It finds the CHaqngeNotififierProvider in Main, that is pointed to the Products()
    final productsData = Provider.of<Products>(context);
    final products = showFavorites ? productsData.favoriteItems : productsData
        .items; // This now taps into the List<Product> items variable in products.dart

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider(
        builder: (ctx) => products[index], // Allows each individual product to have a 
        child: ProductItem(
          // products[index].id,
          // products[index].title,
          // products[index].imageUrl,
        ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //certain amount of columns to fit items
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
