import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iparty/models/user.dart';
import 'package:iparty/providers/users.dart';

import 'package:provider/provider.dart';

import '../screens/home-screen.dart';
import '../screens/profile-edit-screen.dart';
import '../providers/logged-user.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UsersProvider>(context, listen: false).activeUser;

    return Drawer(
      child: ListView(
        children: <Widget>[
          user == null
              ? CircularProgressIndicator()
              : UserAccountsDrawerHeader(
                  accountName: Text(user.displayName),
                  accountEmail: Text(user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: user.imageUrl.isEmpty
                        ? Text(
                            user.displayName[0],
                            style: TextStyle(fontSize: 40.0),
                          )
                        : Image(image: NetworkImage(user.imageUrl)),
                  ),
                ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.games),
            title: Text('Tus mesas'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Tu perfil'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed(EditProfileScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Cerrar sesión'),
            onTap: () async {
              await Provider.of<AuthService>(context, listen: false).logout();
            },
          )
        ],
      ),
    );
  }
}
