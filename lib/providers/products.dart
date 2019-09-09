import 'dart:convert'; // Allows JSON conversion
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

// Mixins must be added to providers
class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];
  // var _showFavoritesOnly = false;
  // A getter to return only favorited items
  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  // A getter to return all items
  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items]; // return a copy of a list of items
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }
  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  // We have this function return a future (now the whole http.post is returned) so we can then refer to it using then() in edit_product_screen to determine if we navigate and pop the screen
  Future<void> addProduct(Product product) {
    // Below uses Http package to send to firebase a new product, imported above using http package
    const url =
        'https://shop-app-a3c02.firebaseio.com/products.json'; // Firebase requires the /endpoint collection like products.json
    return http.post(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
      }), ).then((response) {
        print(json.decode(response.body));
        final newProduct = Product(
            title: product.title,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl,
            id: json.decode(response.body)['name'], // Stores the unique firebase ID as the product's id
          );
          _items.add(newProduct);
          // _items.insert(0, newProduct); // To add to beginning of list
          notifyListeners();
      }); // Url and body which includes data, expected as json, converted by dart:convert package, using a Map
    
  }

  void updateProduct(String id, Product newProduct) {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      // Checks to make sure we aren't updating a product we don't have
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('issue with update');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
