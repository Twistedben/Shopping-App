import 'package:flutter/foundation.dart';
import 'dart:convert'; // Allows JSON conversion

import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price; 
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  // Method to DRY code below and call in favorite failure
  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite; // If true, then false, if false then set true
    notifyListeners(); // Equivalent to setState in stateful widgets, let's providers know the object's state has changed. 
    final url = 'https://shop-app-a3c02.firebaseio.com/products/$id.json'; 
    try {
      final response = await http.patch(url, body: json.encode({
        'isFavorite': isFavorite,
       })
      );
    if (response.statusCode >= 400) {// Checks if there's an error since only get and Post throw exceptions
      _setFavValue(oldStatus);
    }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
