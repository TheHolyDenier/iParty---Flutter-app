import 'package:flutter/material.dart';
import 'package:iparty/providers/logged-user.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  static final routeName = '/home-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesas disponibles'),
      ),
      body: Column(
        children: <Widget>[
          Text('Holis'),
          RaisedButton(
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).logout();
            },
            child: Text('Log-out'),
          ),
        ],
      ),
    );
  }
}
