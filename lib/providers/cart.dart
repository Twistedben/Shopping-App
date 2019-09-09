import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {
    
  }; // It's a map, due to multiple, and each has an ID, hence String, and then CartItem object

  // GEtter for items, returning a copy
  Map<String, CartItem> get items {
    return {..._items};
  }

  // GEtter to return how many items are in cart
  int get itemCount {
    return _items == null ? 0 : _items.length;
  }

  // Getter to return total of items for cart screen
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Function to add items to cart
  void addItem(String productId, double price, String title) {
    // If the product is already in the cart, then we increase quantity, otherwise, it's a new product
    if (_items.containsKey(productId)) {
      // Checks whether the item is already have a entry for the productId
      _items.update(
          // Updates the new item, based on the old item provided by the update function argument
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
              ));
    } else {
      // New product entry to cart
      _items.putIfAbsent(
          // Adds a new value to the map
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  // Function to remove item from the items map
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Remove single item, called in undo in snackbar
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      // Failsafe to make sure product is in cart
      return;
    }
    if (_items[productId].quantity > 1) { // Removes one quantity to the cart if there was already more than one in there
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
    } else { // Removes entire product since just one is in there
      _items.remove(productId);
    }
    notifyListeners();
  }

  // When order is placed, we clear the cart
  void emptyCart() {
    _items = {};
    notifyListeners();
  }
}
