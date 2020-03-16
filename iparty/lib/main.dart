import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import './screens/auth-screen.dart';
import './screens/home-screen.dart';
import './screens/splash-screen.dart';

import './providers/logged-user.dart';

void main() => runApp(
      ChangeNotifierProvider<AuthService>(
        child: MyApp(),
        create: (BuildContext context) {
          return AuthService();
        },
      ),
    );

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
      home: FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // log error to console                                            ⇐ NEW
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }
            // redirect to the proper page, pass the user into the
            // `HomePage` so we can display the user email in welcome msg     ⇐ NEW
            return snapshot.hasData
                ? HomeScreen(/*snapshot.data*/)
                : AuthScreen();
          } else {
            // show loading indicator                                         ⇐ NEW
            return CircularProgressIndicator();
          }
        },
      ),
      // initialRoute: '/',
      routes: {
        // '/': (context) => AuthScreen(),
        AuthScreen.routeName: (context) => AuthScreen(),
        SplashPage.routeName: (context) => SplashPage(),
        HomeScreen.routeName: (context) => HomeScreen(),
      },
    );
  }
}
