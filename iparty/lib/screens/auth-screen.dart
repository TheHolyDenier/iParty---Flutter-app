import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

import './splash-screen.dart';
import '../providers/logged-user.dart';

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
  String _email, _password, _displayName;

  @override
  Widget build(BuildContext context) {
    //Página de intro
    if (_needCheck)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkLaunch(context);
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
        ],
      ),
    );
  }

// Genera el botón de registro
  Widget _buildRegisterButton() {
    var failedRegister = false;
    var errorMessage = '';
    return OutlineButton(
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
      onPressed: () => _onButtonPressed(
        widgets: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Nombre de usuario',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      icon: Icon(
                        Icons.person,
                        color: _themeOf.accentColor,
                      ),
                    ),
                    onSaved: (value) => _displayName = value.trim(),
                    validator: (value) => value.isEmpty
                        ? 'Es necesario escribir un nombre identificativo'
                        : null,
                  ),
                  emailWidget(),
                  passwordWidget(setModalState),
                  if (failedRegister)
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.error, color: _themeOf.errorColor),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: _themeOf.errorColor),
                              softWrap: true,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                    ),
                  RaisedButton(
                    onPressed: () async {
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        // Si todo es correcto
                        form.save();
                        try {
                          FirebaseUser user = (await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _email, password: _password))
                              .user;
                          UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
                          userUpdateInfo.displayName = _displayName;
                          user.updateProfile(userUpdateInfo).then((_) {
                            Firestore.instance
                                .collection('users')
                                .document(user.uid)
                                .setData({
                              'email': _email,
                              'displayName': _displayName
                            }).then((_) async {
                              await Provider.of<
                                      AuthService>(context, listen: false)
                                  .loginUser(email: _email, password: _password);
                                  Navigator.of(context).pop(); 
                            });
                          });
                        } on AuthException catch (error) {
                          //Manejo de errores
                          setModalState(() {
                            failedRegister = true;
                            if (error.code == 'ERROR_NETWORK_REQUEST_FAILED')
                              errorMessage =
                                  'Compruebe que está conectado a Internet y vuelva a intentarlo.';
                            else if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE')
                              errorMessage = 'Ese e-mail ya está en uso.';
                          });
                          print('${error.code}: ${error.message}');
                        } on Exception catch (error) {
                          setModalState(() {
                            failedRegister = true;
                            errorMessage =
                                'Ha habido un error. Compruebe que tenga acceso a Internet y vuelva a intentarlo';
                          });
                          print(error.toString());
                        }
                      } else {
                        // Si no es correcto
                        setModalState(() => _autoValidate = true);
                      }
                    },
                    child: Text('regístrate'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

// Genera el botón de inicio de sesión
  Widget _buildLoginButton() {
    var failedLogging = false, ressetPassword = false, connectionError = false;
    var errorMessage = '';
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
        widgets: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(children: <Widget>[
              emailWidget(),
              passwordWidget(setModalState),
              if (failedLogging) // Muestra mensaje de error de internet
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.error, color: _themeOf.errorColor),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: _themeOf.errorColor),
                          softWrap: true,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
              if (failedLogging && !connectionError)
                ressetPassword //Muestra botón/mensaje de confirmación de recuperación de contraseña
                    ? Text('E-mail enviado. Revise su correo electrónico.')
                    : FlatButton(
                        child: Text(
                          'Recuperar contraseña',
                          style: TextStyle(color: _themeOf.errorColor),
                        ),
                        onPressed: () => FirebaseAuth.instance
                            .sendPasswordResetEmail(email: _email)
                            .then(
                              (_) => setModalState(
                                () {
                                  ressetPassword = true;
                                },
                              ),
                            ),
                      ),
              RaisedButton(
                onPressed: () async {
                  final form = _formKey.currentState;
                  if (form.validate()) {
                    // Si todo es correcto
                    form.save();
                    try {
                      // Inicio de sesión
                      await Provider.of<AuthService>(context, listen: false)
                          .loginUser(email: _email, password: _password);
                      Navigator.of(context).pop();
                    } on AuthException catch (error) {
                      //Manejo de errores
                      setModalState(() {
                        ressetPassword = false;
                        if (error.code == 'ERROR_NETWORK_REQUEST_FAILED') {
                          errorMessage =
                              'Compruebe que está conectado a Internet y vuelva a intentarlo.';
                          connectionError = true;
                          failedLogging = true;
                        } else {
                          errorMessage =
                              'La contraseña y el e-mail no coinciden';
                          failedLogging = true;
                          connectionError = false;
                        }
                      });
                      print('${error.code}: ${error.message}');
                    } on Exception catch (error) {
                      setModalState(() {
                        failedLogging = true;
                        errorMessage =
                            'Ha habido un error. Vuelva a intentarlo';
                      });
                      print(error.toString());
                    }
                  } else {
                    // Si no es correcto
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

  Widget emailWidget() {
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
      validator: (value) {
        var error;
        if (value.isEmpty)
          error = 'Es necesario escribir un e-mail';
        else if (!EmailValidator.validate(value.trim()))
          error = 'Es necesario escribir un e-mail válido';
        return error;
      },
      onSaved: (value) => _email = value.trim(),
    );
  }

  Widget passwordWidget(StateSetter setModalState) {
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
              error = 'Es necesario escribir una contraseña';
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
                        style: Theme.of(context).textTheme.headline1,
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
  void _onButtonPressed({Widget widgets}) {
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
                      child: widgets, //widgets del modal
                      padding: EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 10.0),
                    ),
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
