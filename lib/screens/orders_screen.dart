import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  // Below - Converted to a Stateful widget so that we can use initState and Future delay to call fetchOrders from Orders.dart class.
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
         _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).fetchOrders();
      setState(() {
        _isLoading = false;
      });
    }); // This is queued at the end of initialization.
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold (
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: _isLoading 
      ? 
        Center(child: CircularProgressIndicator()) 
      : 
        ListView.builder(
          itemCount: orderData.orders.length,
          itemBuilder: (ctx, index) => OrderItem(
            orderData.orders[index],
          ),
        ),
      drawer: AppDrawer(),
    );
  }
}
