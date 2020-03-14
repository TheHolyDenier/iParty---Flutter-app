import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iparty/screens/main-screen.dart';

import './login-screen.dart';

import '../services/auth.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootScreen extends StatefulWidget {
  final BaseAuth auth;

  RootScreen({this.auth});

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  var _logging = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _checkLogging();
      }
    } on SocketException catch (_) {
      _logging = false;
    }
  }

  void _redirect() {
    switch (authStatus) {
      case AuthStatus.LOGGED_IN:
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
        break;
      case AuthStatus.NOT_LOGGED_IN:
        Navigator.pushReplacementNamed(context, AuthScreen.routeName);
        break;
      default:
        _logging = false;
        break;
    }
  }

  void _checkLogging() {
    _logging = true;
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
        _redirect();
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
          child: ListView(
            children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      _logging
                          ? Text('Conectando')
                          : Text(
                              'Sin conexión a internet',
                              style: TextStyle(color: Theme.of(context).errorColor),
                            ),
                      SizedBox(
                        width: 10.0,
                      ),
                      _logging
                          ? CircularProgressIndicator()
                          : Icon(Icons.error, color: Theme.of(context).errorColor),
                      Spacer(),
                    ],
                  ),
                ),
            ],
          ),
        onRefresh: () async {
          setState(() {
            _logging = true;
            _checkInternet();
          });
        },
      ),
    );
  }
}
