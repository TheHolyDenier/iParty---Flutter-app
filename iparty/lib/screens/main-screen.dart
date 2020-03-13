import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import './splash-screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _checkLaunch(context);
    return Scaffold(appBar: AppBar(title: Text('Mesas disponibles'),),body: Container(
    ),);
  }

  void _checkLaunch(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('firstLaunch') == null) {
      Navigator.of(context).pushNamed(SplashPage.routeName);
      await prefs.setInt('firstLaunch', 1);
    } 

  }
}
