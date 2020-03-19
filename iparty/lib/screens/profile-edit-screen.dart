import 'package:flutter/material.dart';
import 'package:iparty/widgets/drawer.dart';

class EditProfileScreen extends StatefulWidget {
  static final routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tu perfil')),
      drawer: MyDrawer(),
      body: Center(
          child: Column(
        children: <Widget>[
          
        ],
      )),
    );
  }
}
