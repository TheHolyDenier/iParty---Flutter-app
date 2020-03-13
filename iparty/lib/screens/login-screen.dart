import 'package:flutter/material.dart';

class AccessScreen extends StatefulWidget {
  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // TextEditingController _emailController = new TextEditingController();
  // TextEditingController _passwordController = new TextEditingController();
  // TextEditingController _nameController = new TextEditingController();
  // String _email;
  // String _password;
  // String _displayName;
  // bool _obsecure = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            logo(),
            _buildRaisedButton(),
            _buildOutlineButton()
          ],
        ));
  }

  OutlineButton _buildOutlineButton() => OutlineButton(
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
        onPressed: () {},
      );

  RaisedButton _buildRaisedButton() => RaisedButton(
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
        onPressed: () => _onButtonPressed(),
      );

  Widget logo() {
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

  void _onButtonPressed() {
    var themeOf = Theme.of(context);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                          color: themeOf.accentColor,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Padding(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'correo electrónico',
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              icon: Icon(
                                Icons.email,
                                color: themeOf.accentColor,
                              ),
                            ),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'contraseña',
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              icon: Icon(
                                Icons.lock,
                                color: themeOf.accentColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: RaisedButton(
                              onPressed: () {},
                              child: Text('iniciar sesión'),
                            ),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10.0),
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
}
