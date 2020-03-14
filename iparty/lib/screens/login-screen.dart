import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import './splash-screen.dart';

class AuthScreen extends StatefulWidget {
  static final routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  ThemeData _themeOf;
  bool _obscureText = true;
  String _email, _password;


  @override
  Widget build(BuildContext context) {
    _checkLaunch(context);
    _themeOf = Theme.of(context);
    return Scaffold(
      backgroundColor: _themeOf.primaryColor,
      body: Column(
        children: <Widget>[
          _genLogo(),
          _buildLoginButton(),
          _buildRegisterButton()
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
  Widget _buildLoginButton() => RaisedButton(
        elevation: 0.0,
        splashColor: Colors.white,
        highlightColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
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
            return Column(children: <Widget>[
              emailWidget(),
              passwordWidget(setModalState),
            ]);
          }),
        ),
      );

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
              error = 'La contraseña debe de tener al menos seis caracteres';
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
                ? Icon(Icons.enhanced_encryption)
                : Icon(Icons.no_encryption),
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
                    RaisedButton(
                      onPressed: buttonFunction,
                      child: Text(buttonText),
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
}
