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
    resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(children: <Widget>[
              logo(),
              _buildRaisedButton(),
              _buildOutlineButton()],));
        }
      
        OutlineButton _buildOutlineButton() => OutlineButton(
        borderSide: BorderSide( width: 2.0),
        splashColor: Colors.white,
        highlightColor: Colors.white,
          highlightedBorderColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
           ),
         child: Text("regístrate",style: TextStyle(
            fontSize: 20),),
          onPressed: () { 
          },
          );
      
        RaisedButton _buildRaisedButton()  => RaisedButton(
              elevation: 0.0,
                splashColor: Colors.white,
        highlightColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              child: Text(
                'inicia sesión',
                style: TextStyle(
                     fontSize: 20,),
              ),
              onPressed: () => null,
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
                              shape: BoxShape.circle, color: Theme.of(context).accentColor,),
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
                              Image(image: AssetImage('assets/images/goblin_dice.png'), width: 150,),
                            ],
                          ),
                          ),
                    ),
                    Positioned(
                        child: Container(
                      child: Center(
                        child: Container(
                         child: Center(child: Text('iParty', style: Theme.of(context).textTheme.title,),),
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
                         child: Center(child: Text('el tinder (platónico) para goblins',),),
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
      }
      
