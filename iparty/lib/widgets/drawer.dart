import 'package:flutter/material.dart';
import 'package:iparty/models/user.dart';
import 'package:iparty/providers/users.dart';
import 'package:iparty/widgets/avatar-circles.dart';

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
          Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            height: 150.0,
            child: user == null
                ? Container(
                    width: 50,
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 60,
                              height: 60,
                              child: user.imageUrl.isEmpty
                                  ? MyTextAvatarCircle(user.displayName[0])
                                  : MyImageAvatarCircle(user.imageUrl, true),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    user.displayName,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                  Text(
                                    user.email,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
