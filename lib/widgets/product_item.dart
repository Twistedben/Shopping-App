import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id, title, imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    // Below is provided in Products_grid via the ChaangeNotifierProvider builder
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    // Below we get the authToken to pass to toggleFavorite to update the favorite status on firebase
    final authData = Provider.of<Auth>(context, listen: false);
    // An alternative to using the above provider is to use COnsumer widget which can wrap the areas of your widget tree that will change, so that way it won't rebuild the whole widget each time but just the area that does update, setting provider to listen false.
    // return Consumer<Product>(builder: ctx, product, child) => ClipRRect(ALL BELOW WIDGETS) Or just the section of widget that will update.
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            color: Theme.of(context).accentColor,
            onPressed: () {
              product.toggleFavorite(authData.token, authData.userId);
            },
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context)
                  .hideCurrentSnackBar(); // Removes the existing Snackbar to show the new one in its place
              // Establishes a connection with nearest Scaffold widget. Cannot be used inside a Scaffold. IN this case, it goes to ProductsOverviewScreen
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  // Info modal at bottom of screen (flash)
                  content: Text(
                    'Added ${product.title} to cart!',
                  ),
                  duration: Duration(seconds: 4),
                  action: SnackBarAction(
                    // WIdget that needs a label and onpressed, allows user input action
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
