import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/orders.dart' show Orders;
import 'package:shops_app/widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders-screen';
  // @override
  // void initState() {
  //   _isLoading = true;
  //   Provider.of<Orders>(context, listen: false).fetchOrders().then((_) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapshot.error != null) {
            return Center(
              child: Text('An Error occured'),
            );
          } else {
            return Consumer<Orders>(
              builder: (ctx, orderData, child) => orderData.orders.length <= 0
                  ? Center(
                      child: Text('No orders yet !', 
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (_, i) => OrderItem(orderData.orders[i]),
                    ),
            );
          }
        },
      ),
    );
  }
}
