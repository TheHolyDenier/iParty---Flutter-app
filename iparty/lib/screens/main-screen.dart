import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './login-screen.dart';

class MainScreen extends StatelessWidget {
  static final routeName = '/main-screen';

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesas disponibles'),
      ),
      body: Container(
        child: Text('Holis'),
      ),
    );
  }
}
