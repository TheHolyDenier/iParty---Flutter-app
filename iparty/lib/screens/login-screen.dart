import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './main-screen.dart';
import './splash-screen.dart';

class AuthScreen extends StatefulWidget {
  static final routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseUser user;
  ThemeData _themeOf;
  bool _obscureText = true, _autoValidate = false, _needCheck = true;
  String _email, _password;

  
  @override
  Widget build(BuildContext context) {
    if (_needCheck) WidgetsBinding.instance.addPostFrameCallback((_) {
      // var user = Provider.of<FirebaseUser>(context, listen: false);
      // if (user != null) {
      //   Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
      // } else {
      //   print('No user');
      //   _checkLaunch(context);
      // }
      _needCheck = false; 
    });

    _themeOf = Theme.of(context);

    //Página principal
    return Scaffold(
      backgroundColor: _themeOf.primaryColor,
      body: Column(
        children: <Widget>[
          _genLogo(),
          _buildLoginButton(),
          _buildRegisterButton(),
          RaisedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('log-out'),
          ),
        ],
      ),
    );
  }

// Genera el botón de registro
  Widget _buildRegisterButton() => OutlineButton(
      borderSide: BorderSide(width: 2.0),
      splashColor: Colors.white,
      highlightColor: Colors.white,
      highlightedBorderColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(30.0),
      ),
      child: Text(
        "regístrate",
        style: TextStyle(fontSize: 20),
      ),
      onPressed: () {} // => _onButtonPressed(<Widget>[], 'regístrate', () {}),
      );

// Genera el botón de inicio de sesión
  Widget _buildLoginButton() {
    var failedLogging = false;
    return RaisedButton(
      elevation: 0.0,
      splashColor: Colors.white,
      highlightColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      child: Text(
        'inicia sesión',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      onPressed: () => _onButtonPressed(
        buttonText: 'inicia sesión',
        buttonFunction: () {},
        widgets: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(children: <Widget>[
              if (failedLogging)
                Row(
                  children: <Widget>[
                    Icon(Icons.error, color: _themeOf.errorColor),
                    SizedBox(width: 10.0),
                    Text(
                      'Datos de inicio de sesión erróneos',
                      style: TextStyle(color: _themeOf.errorColor),
                    ),
                  ],
                ),
              emailWidget(),
              passwordWidget(setModalState),
              RaisedButton(
                onPressed: () {
                  final form = _formKey.currentState;
                  if (form.validate()) {
                    form.save();
                    _firestoreAuth(context, setModalState, failedLogging);
                  } else {
                    setModalState(() => _autoValidate = true);
                  }
                },
                child: Text('inicia sesión'),
              ),
            ]),
          );
        }),
      ),
    );
  }

  Future<Object> _firestoreAuth(BuildContext context, StateSetter setModalState, bool failedLogging) async {
    String errorMessage;
    try {
      AuthResult result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _email, password: _password);
      //           .then((result) {
      //   print(result.user.uid);
        Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
      // });
      user = result.user;
    } catch (error) {
      print('No user');
      setModalState(() {
        failedLogging = true;
      });
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage =
              "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your password is wrong.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage =
              "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage =
              "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
    }
    
    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
    return user.uid;
  }

  TextFormField emailWidget() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'correo electrónico',
        hintStyle: TextStyle(fontWeight: FontWeight.bold),
        icon: Icon(
          Icons.email,
          color: _themeOf.accentColor,
        ),
      ),
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: (value) =>
          value.isEmpty ? 'Es necesario escribir un e-mail' : null,
      onSaved: (value) => _email = value.trim(),
    );
  }

  Stack passwordWidget(StateSetter setModalState) {
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
            hintText: 'contraseña',
            hintStyle: TextStyle(fontWeight: FontWeight.bold),
            contentPadding:
                const EdgeInsets.fromLTRB(6, 6, 48, 6), // 48 -> ancho del icono
            icon: Icon(
              Icons.lock,
              color: _themeOf.accentColor,
            ),
          ),
          maxLines: 1,
          autofocus: false,
          obscureText: _obscureText, //La contraseña se muestra oculta
          validator: (value) {
            var error;
            if (value.isEmpty)
              error = 'Es necesario escribir un e-mail';
            else if (value.trim().length < 6)
              error = 'Contraseña demasiado corta';
            return error;
          },
          onSaved: (value) => _password = value.trim(),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            color: _themeOf.accentColor,
            onPressed: () {
              setModalState(
                () {
                  _obscureText = !_obscureText;
                  print(_obscureText.toString());
                },
              );
            },
            icon: _obscureText
                ? Icon(Icons.visibility)
                : Icon(Icons.visibility_off),
          ),
        ),
      ],
    );
  }

// Genera el logo
  Widget _genLogo() {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(top: 120),
      child: Container(
        width: double.infinity,
        height: 240,
        child: Stack(
          children: <Widget>[
            Positioned(
                child: Container(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).accentColor,
                  ),
                  width: 150,
                  height: 150,
                ),
              ),
              height: 154,
            )),
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Image(
                      image: AssetImage('assets/images/goblin_dice.png'),
                      width: 150,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: Container(
                child: Center(
                  child: Container(
                    child: Center(
                      child: Text(
                        'iParty',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                  ),
                ),
              ),
              height: 50,
              left: 100,
            ),
            Positioned(
              child: Container(
                child: Center(
                  child: Container(
                    child: Center(
                      child: Text(
                        'el tinder (platónico) para goblins',
                      ),
                    ),
                  ),
                ),
              ),
              height: 380,
              left: 120,
            ),
          ],
        ),
      ),
    ));
  }

// Abre el desplegable desde la parte inferior
  void _onButtonPressed(
      {Widget widgets, String buttonText, Function buttonFunction}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                // topLeft: Radius.circular(20.0),
                topRight: Radius.circular(30.0),
              ),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: FlatButton(
                        child: Icon(
                          Icons.close,
                          color: _themeOf.accentColor,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Padding(
                      child: Column(
                        children: <Widget>[widgets],
                      ),
                      padding: EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 10.0),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: 20.0),
                    //   child:
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Comprueba si se trata de la primera vez que abres la aplicación
  void _checkLaunch(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('firstLaunch') == null) {
      Navigator.of(context).pushNamed(SplashPage.routeName);
      await prefs.setInt('firstLaunch', 1);
    }
  }

  //   void _checkLogging() {
  //   _logging = true;
  //   widget.auth.getCurrentUser().then((user) {
  //     setState(() {
  //       if (user != null) {
  //         _userId = user?.uid;
  //       }
  //       authStatus =
  //           user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
  //       _redirect();
  //     });
  //   });
  // }

}
