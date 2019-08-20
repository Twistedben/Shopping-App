import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import './cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop',
        ),
        actions: <Widget>[
          Consumer<Cart>(
            // Sets up a provider for cart and will only rebuild this area when updated, the badge area, however the ChildIcon area of the consumer will not rebuild since it's using the child: prop of consumner
            builder: (_, cart, childIcon) => Badge(
              child: childIcon,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              // Since child is defined outside of builder function, it will not rebuild each time the value changed, since all we want is the badge to rebuild
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: const Text(
                  'Only Favorites',
                ),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: const Text(
                  'Show All',
                ),
                value: FilterOptions.All,
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: ProductsGrid(_showOnlyFavorites),
    );
  }
}
