import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart'
    show
        Cart; // Will only import Cart class and not CartItem to avoid name clash
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(), // Takes up all available space between
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                              Theme.of(context).primaryTextTheme.title.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart), // Widget is defined below, extracted using refactor 'extract widget' since we'll only use it here, we keep it in the same file
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx, index) => CartItem(
                  // BEcause CartItem is stored in a Map, we have to access the values there as a list
                  cart.items.values.toList()[index].id,
                  cart.items.keys.toList()[index], // ProductId
                  cart.items.values.toList()[index].title,
                  cart.items.values.toList()[index].price,
                  cart.items.values.toList()[index].quantity),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
      onPressed: (widget.cart.totalAmount <= 0  || _isLoading) ? null : () async { // Null will disable button. Async needed since addOrder now returnsd a future
        setState(() {
          _isLoading = true; 
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
          widget.cart.items.values.toList(),
          widget.cart.totalAmount,
        );
        setState(() {
          _isLoading = false; 
        });
        widget.cart.emptyCart();
      },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
