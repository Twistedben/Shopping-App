import 'dart:convert'; // Allows JSON conversion
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

// Mixins must be added to providers
class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
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

  // Below - We have a future that fetches the products added from firebase. We call this inside products_overview_screen initstate()
  Future<void> fetchAndSetProducts() async {
    const url = 'https://shop-app-a3c02.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      // print(json.decode(response.body)); // Good way to see how the mapped data is retrieved and how we can extract and digest that data
      final fetchedData = json.decode(response.body) as Map<String, dynamic>; // Says we have a Map coming in where the keys are strings and values are dynamic (The values are also Maps but declaring that would give us a error)
      if (fetchedData == null) {    // If there are no products on server, break out and return nothing.
        return; 
      }
      final List<Product> loadedProducts = [];
      // FOr each entry in the map, we'll execute a function 
      fetchedData.forEach((prodId, prodData) { // We need convert the data into product objects based on our Product class, since we need product from items
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts; // Assigns the above empty NONFINAL variable with the new loadedProducts array/list
      notifyListeners(); // Lets products_overview_screen know things have changed
    } catch (error) {
      throw (error);
    }
  }

  // We have this function return a future (now the whole http.post is returned) so we can then refer to it using then() in edit_product_screen to determine if we navigate and pop the screen
  Future<void> addProduct(Product product) async { // Using async keyword here, will wrap the whole function into a future, returning one, so return keyword is not needed. You can use this on any code you think might fails
  //Future<void> addProduct(Product product) { // Using non-async will require a return keyword preceeding the http instead of await
    // Below uses Http package to send to firebase a new product, imported above using http package
    const url =
        'https://shop-app-a3c02.firebaseio.com/products.json'; // Firebase requires the /endpoint collection like products.json
    try {   // needed with async, is like then()
      final response = await http // Await wraps all the code that comes after it, allowing then() and catchError() to be removed. Works like synchronous code
      //return http // Return is required without async 
          .post(
        // Url and body which includes data, expected as json, converted by dart:convert package, using a Map
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'], // Stores the unique firebase ID as the product's id
      );
      _items.add(newProduct); // Adds at end of list
      // _items.insert(0, newProduct); // To add to beginning of list
      notifyListeners(); 
    } catch (error) { // Needed with async, is like catchError()
      print(error);
      throw error; 
    }
      // .then((response) { // Needed without async
      //print(json.decode(response.body));
      // final newProduct = Product(
      //   title: product.title,
      //   description: product.description,
      //   price: product.price,
      //   imageUrl: product.imageUrl,
      //   id: json.decode(response.body)['name'], // Stores the unique firebase ID as the product's id
      // );
      // _items.add(newProduct); // Adds at end of list
      // // _items.insert(0, newProduct); // To add to beginning of list
      // notifyListeners();
    //}).catchError((error) { // Needed without async
     // print(error);
     // throw error; // Will create a new error so we can use it inside edit_product_screen instead of in here to make use of changing state there and user feedback, otherwise without throw error, the erorr is handled and exits here
    //}); // Add catchError() after the initial post and the then() to ensure it's attempted, and then when failed, we execute catchError
    
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = 'https://shop-app-a3c02.firebaseio.com/products/$id.json'; // Here we use to get the id for the specific product and provide it for the url endpoint. We have to use final instead of const since it'll only be final at runtime and not compilation time
      await http.patch(url, body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
      }));
     // Checks to make sure we aren't updating a product we don't have
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('issue with update');
    }
  }

  // Below we utilize optimistic updating.
  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-app-a3c02.firebaseio.com/products/$id.json'; // Here we use to get the id for the specific product and provide it for the url endpoint. We have to use final instead of const since it'll only be final at runtime and not compilation time
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id); // Finds the deleting products index.
    var existingProduct = _items[existingProductIndex];                   // Uses the index to find the deleting product.
    _items.removeAt(existingProductIndex);  // Removes the deleting item from the list, but not in memory
    notifyListeners();
    final response = await http.delete(url);
    // Below ensures that the http request succeeds before removing it from in memory, and if it fails, then readds it to the list.
    // Below we build our own error to ensure that if there's an error, we can handle it. Goes to models/http_exception.dart
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct); // If for some reason removal fails, then we can readd that deleted item back into the list.
      notifyListeners(); 
      throw HttpException('Could not delete product.'); 
    } 
    existingProduct = null;   // It was deleted in firebase, so delete it in memory, too.
    // _items.removeWhere((prod) => prod.id == id);
  }
}
