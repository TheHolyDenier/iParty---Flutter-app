import 'package:flutter/material.dart';
import 'package:iparty/screens/splash-screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _checkLaunch(context);
    return Scaffold();
  }

  void _checkLaunch(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('firstLaunch') == null) {
      await prefs.setInt('firstLaunch', 0);
      Navigator.of(context).pushNamed(SplashPage.routeName);
    }
  }
}
