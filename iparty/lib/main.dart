import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<int, Color> primarySwatchMap = {
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

    return MaterialApp(
      title: 'iParty',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF92c5e0, primarySwatchMap),
        accentColor: Color.fromRGBO(255, 182, 161, 1),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(255, 182, 161, 1),
        ),
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
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('holis'),
      ),
      body: Container(
        child: RaisedButton(
          onPressed: () {},
          child: Text('Holis'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('+'),
      ),
    );
  }
}
