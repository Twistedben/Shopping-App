import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://shop-app-a3c02.firebaseio.com/orders.json'; 
    final dateTime = DateTime.now();
    try {
      final response = await http.post(url, body: json.encode({
        'amount': total, 
        'dateTime': dateTime.toIso8601String(), // iso8601 string will allow reconversion back to DateTime
        'products': cartProducts.map((cp) => {
          'id': cp.id, 
          'title': cp.title, 
          'quantity': cp.quantity, 
          'price': cp.price, 
        }).toList() // Since products is cartProducts which is a list of CartItems, we need to make it a map
      }));
      _orders.insert(  // insert 0 adds to beginning of list
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              dateTime: dateTime,
              products: cartProducts
            )
      ); 
      notifyListeners();
    } catch (error) {
      notifyListeners();
      throw error; 
    }
  }

  Future<void> fetchOrders() async {
    const url = 'https://shop-app-a3c02.firebaseio.com/orders.json';
    try {
      final response = await http.get(url);
      final fetchedOrders = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = []; 
      if (fetchedOrders == null) {    // If there are no orders on server, break out and return nothing.
        return; 
      }
      fetchedOrders.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'], 
          dateTime: DateTime.parse(orderData['dateTime']),
          // Since we products this is a list (List<CartItem>), we first take it in and convert it to a list, the value is dynamic, and then we map it and append toList()
          products: (orderData['products'] as List<dynamic>)
            .map(
              (item) => CartItem(
                id: item['id'], price: item['price'], quantity: item['quantity'], title: item['title']
              )
          ).toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList(); // Reverses the order so time is chronological
      notifyListeners();
    } catch (error) {

      notifyListeners();
    }
  }

}
