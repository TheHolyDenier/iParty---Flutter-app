import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iparty/screens/login-screen.dart';
import 'package:iparty/screens/main-screen.dart';
import 'package:iparty/screens/root-screen.dart';
import 'package:iparty/services/auth.dart';

import './screens/splash-screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<int, Color> _primarySwatchMap = {
      50: Color.fromRGBO(146, 197, 224, .1),
      100: Color.fromRGBO(146, 197, 224, .2),
      200: Color.fromRGBO(146, 197, 224, .3),
      300: Color.fromRGBO(146, 197, 224, .4),
      400: Color.fromRGBO(146, 197, 224, .5),
      500: Color.fromRGBO(146, 197, 224, .6),
      600: Color.fromRGBO(146, 197, 224, .7),
      700: Color.fromRGBO(146, 197, 224, .8),
      800: Color.fromRGBO(146, 197, 224, .9),
      900: Color.fromRGBO(146, 197, 224, 1),
    };

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'iParty',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF92c5e0, _primarySwatchMap),
        accentColor: Color.fromRGBO(255, 182, 161, 1),
        hintColor: Color.fromRGBO(255, 212, 161, 1),
        errorColor: Color.fromRGBO(237, 74, 56, 1),
        fontFamily: 'OpenSans',
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(
              fontSize: 36.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'PTSansNarrow'),
          body1: TextStyle(fontSize: 14.0),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(255, 182, 161, 1),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.transparent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RootScreen(auth: new Auth()),
        SplashPage.routeName: (context) => SplashPage(),
        AuthScreen.routeName: (context) => AuthScreen(),
        MainScreen.routeName: (context) => MainScreen(),
      },
    );
  }
}
