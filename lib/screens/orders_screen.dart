import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
  // var _isLoading = false;

  // Below - Converted to a Stateful widget so that we can use initState and Future delay to call fetchOrders from Orders.dart class.
  // @override
  // void initState() {
  //   super.initState();
  // Approach 1: 
    // Future.delayed(Duration.zero).then((_) async {
    //   setState(() {
    //      _isLoading = true;
    //   });
    //   await Provider.of<Orders>(context, listen: false).fetchOrders();
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }); // This is queued at the end of initialization.
  // Approach 2: 
    // _isLoading = true; 
    // Provider.of<Orders>(context, listen: false).fetchOrders().then((_) {
    //   setState(() {
    //     _isLoading = false;
    //   });  
    // });
  // Approach 3: FutureBuillding below in body: BEST APPROACH for performance and leanness
    // There we don't use initstate or set state with a prop like isLoading, instead check if the future resolved and dictate which is shown dependent on status of future.
    // This also allows us to use a Stateless widget instead of Stateful just to use initState
  // }


  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context); // Having this here will cause an infinite loop of notifylisteners and rebuilding. So instead we set up a consumer below in listview builder where we use order data
    return Scaffold (
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      // Below - The future is the one returned by Provider and fetchOrders(), .waiting is it in progress of fetching, .error is a failure, the else on that is the resolution and completion
      body: FutureBuilder(future: Provider.of<Orders>(context, listen: false).fetchOrders(), 
      builder: (ctx, dataFromFuture) {
        if (dataFromFuture.connectionState == ConnectionState.waiting ) { // Fetching the orders is waiting/loading so show circular progress indicator
          return Center(child: CircularProgressIndicator());
        } else {
          if (dataFromFuture.error != null ) { // Have an error
            // Handle error
            return Center(child: Text("A error has occured"));
          } else {    // Future has resolved successfully, fetchingorders from the futurebuilder above, so show them.
            return Consumer<Orders>(
              builder: (ctx, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, index) => OrderItem(
                  orderData.orders[index],
                ),
              ),
            );
          }
        }
      }),
      drawer: AppDrawer(),
    );
  }
}
