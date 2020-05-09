import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'avatar-circles.dart';
import 'dialog-sure-widget.dart';

import '../models/user.dart';

class DialogDeleteUser extends StatefulWidget {
  final Map<String, User> listUsers;
  final String uid;
  final Function callback;

  DialogDeleteUser(this.listUsers, this.uid, this.callback);

  @override
  _DialogDeleteUserState createState() =>
      _DialogDeleteUserState(listUsers, uid, callback);
}

class _DialogDeleteUserState extends State<DialogDeleteUser> {
  Map<String, User> _listUsers;
  final String uid;
  final Function callback;

  _DialogDeleteUserState(this._listUsers, this.uid, this.callback);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Eliminar usuarios'),
      content: _showPlayers(),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cerrar'),
        )
      ],
    );
  }

  Widget _showPlayers() {
    List<User> users = List();
    _listUsers.forEach((key, value) => users.add(value));
    users.removeAt(0);
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        User user = users[index];
        return ListTile(
          leading: user.imageUrl == ''
              ? MyTextAvatarCircle(user.displayName[0])
              : MyImageAvatarCircle(user.imageUrl, true),
          title: Text('${user.displayName}'),
          trailing: IconButton(
            onPressed: () {
              showDialog<int>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return DialogSureWidget(
                      'Va a eliminar a ${user.displayName}', '¿Está seguro?');
                },
              ).then((value) {
                if (value == 1) {
                  _updateFirebase(user, context);
                }
              });
            },
            icon: Icon(Icons.delete),
          ),
        );
      },
    );
  }

  void _updateFirebase(User user, BuildContext context) {
    Firestore.instance.collection('parties').document(uid).updateData({
      'playersUID': FieldValue.arrayRemove(['${user.uid}'])
    }).then((_) {
      setState(() {
        _listUsers.remove('${user.uid}');
        callback(_listUsers);
      });
      if (_listUsers.length == 1) {
        Navigator.of(context).pop();
      }
    });
  }
}
