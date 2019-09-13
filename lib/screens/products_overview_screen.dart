import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import './cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

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
  var _isInit = true;
  var _isLoading = false;
  // To fetch data here to display the list from firebase, initState() would be acceptable to use, the downside is too much logic inside the widget
    // So instead we move the logic to the products class, products.dart, so that way we just call a method inside initstate to keep it lean. Below
  @override
  void initState() {
    super.initState();
    // Approach 1, if listen: false was set.
      // Provider.of<Products>(context).fetchAndSetProducts(); // Wont Work here. Would if listen: false was set, then we could use of(context) inside initState()
    // Approach 2: See orders_screen to see this in action.
      // Future.delayed(Duration.zero).then((_) {
      //   Provider.of<Products>(context).fetchAndSetProducts();
      // });
    // Approach 3:
      // Use didChangeDependencies instead of initState()
  }

  // Here we use didChange to fetch the products from Firebase. The difference from initState() is this will run multiple times on a widget. Which is why we use _isInit helper to make sure it runs only when needed, at first
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      }
      );
    }
    _isInit = false;
  }

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
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : ProductsGrid(_showOnlyFavorites),
    );
  }
}
