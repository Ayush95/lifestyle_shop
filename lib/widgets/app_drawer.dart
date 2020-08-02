import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/auth.dart';
import 'package:shops_app/screens/auth_screen.dart';
import 'package:shops_app/screens/order_screen.dart';
import 'package:shops_app/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hi There !'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('Orders'),
            onTap: () => Navigator.of(context).pushReplacementNamed(
              OrderScreen.routeName,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Orders'),
            onTap: () => Navigator.of(context).pushReplacementNamed(
              UserProductsScreen.routeName,
            ),
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log out'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                  AuthScreen.routeName,
                );
                Provider.of<Auth>(context, listen: false).logout();
              }),
        ],
      ),
    );
  }
}
