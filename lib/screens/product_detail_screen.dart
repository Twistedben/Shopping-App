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
      listen:
          false, // listen false will NOT rebuild the widget each time when notifyListeners is called. Since this is a show page, you don't need to update.
    ).findById(productId);
    return Scaffold(
      // We replace appBar since below in customscrollview we use that.
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      // body: SingleChildScrollView(
      // Replace SingleChildScrollView with CustonScrollView, allowing us more control, so we can implement animation of making the image the appbar
      body: CustomScrollView(
        // CustomScrollView takes slivers which are scrollable areas on the screen
        slivers: <Widget>[
          // SliverAppBar is what should dynamically change into the appbar
          SliverAppBar(
            expandedHeight: 300, // Height for appbar and not the image
            pinned: true, // Remain visible
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                loadedProduct.title,
                style: TextStyle(fontSize: 24),
              ),
              background: Hero(
                // What should be visible if the appbar is expanded
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              Text(
                '\$${loadedProduct.price}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                height: 800,
              ),
            ]),
          ),
        ],
        // child: Column(
        //   children: <Widget>[
        //     Container(
        //       height: 300,
        //       width: double.infinity,
        //       // Corresponds to the Hero in Product_item.dart image. The Tag should be equal to the previous, connecting hero.
        //       child: Hero(
        //         tag: loadedProduct.id,
        //         child: Image.network(
        //           loadedProduct.imageUrl,
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),

        //   ],
        // ),
      ),
    );
  }
}
