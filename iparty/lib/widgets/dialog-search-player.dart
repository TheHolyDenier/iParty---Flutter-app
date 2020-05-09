import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import './avatar-circles.dart';
import '../models/user.dart';
import '../models/party.dart';

class DialogSearchPlayer extends StatefulWidget {
  final Party party;
  final Function callback;
  final Map<String, User> listUsers;

  DialogSearchPlayer(this.party, this.callback, this.listUsers);

  @override
  _DialogSearchPlayerState createState() =>
      _DialogSearchPlayerState(party, callback, listUsers);
}

class _DialogSearchPlayerState extends State<DialogSearchPlayer> {
  _DialogSearchPlayerState(this._party, this._callback, this._listUsers);

  Map<String, User> _listUsers;
  Party _party;
  Function _callback;

  final _databaseReference = Firestore.instance;
  String _email;
  final _formKey = GlobalKey<FormState>();
  User _user;
  StatusJoin _statusJoin = StatusJoin.NaN;
  var _found = true;
  String _errorFound;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Añadir usuario:'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _input(),
            if (_user != null) _userFound(),
            if (!_found)
              ListTile(
                trailing: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                title: FittedBox(child: Text(_errorFound)),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        RaisedButton(
          child: Text('Buscar'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              FocusScope.of(context).unfocus();
              _getUser();
            }
          },
        )
      ],
    );
  }

  Widget _userFound() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: _user.imageUrl == ''
              ? MyTextAvatarCircle(_user.displayName[0])
              : MyImageAvatarCircle(_user.imageUrl, true),
          title: Text(_user.displayName),
          trailing: IconButton(
            onPressed: () {
              _addUser();
            },
            icon: Icon(Icons.person_add),
          ),
        ),
        _statusJoin == StatusJoin.NaN
            ? Container()
            : _statusJoin == StatusJoin.Ok
                ? Text(
                    'Usuario añadido con éxito',
                    style: TextStyle(color: Colors.green),
                  )
                : Text(
                    'Error. Vuelva a intentarlo más tarde',
                    style: TextStyle(color: Colors.red),
                  )
      ],
    );
  }

  Widget _input() {
    return Form(
      key: _formKey,
      autovalidate: false,
      child: TextFormField(
        decoration: const InputDecoration(
            labelText: 'E-mail del jugador',
            suffixIcon: Icon(Icons.alternate_email)),
        validator: (email) {
          if (!EmailValidator.validate(email)) {
            return 'Introduzca un e-mail válido';
          }
          setState(() {
            _email = email;
          });
          return null;
        },
      ),
    );
  }

  _getUser() {
    _databaseReference
        .collection('users')
        .where('email', isEqualTo: _email)
        .getDocuments()
        .then((QuerySnapshot value) {
      if (value.documents.length > 0) {
        var user = User.fromFirestore(value.documents[0]);
        if (!_party.playersUID.contains(user.uid)) {
          setState(() {
            _user = user;
            _found = true;
          });
        } else {
          setState(() {
            _user = null;
            _errorFound = 'Usuario ya en partida';
            _found = false;
          });
        }
      } else {
        setState(() {
          _user = null;
          _errorFound = 'Ningún usuario con ese e-mail';
          _found = false;
        });
      }
    });
  }

  void _addUser() {
    setState(() {
      _statusJoin = StatusJoin.NaN;
    });
    _databaseReference.collection('parties').document(_party.uid).updateData({
      'playersUID': FieldValue.arrayUnion(['${_user.uid}']),
    }).then((_) {
//      Sets ok message
      setState(() {
        _statusJoin = StatusJoin.Ok;
        _listUsers.putIfAbsent(_user.uid, () => _user);
        _callback(_listUsers);
        _user = null;
        _formKey.currentState.reset();
      });
    }).catchError((error) {
      // Not ok
      setState(() {
        _statusJoin = StatusJoin.Error;
      });
      print(error.toString());
    });
  }
}
