import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:iparty/models/user.dart';

import 'package:provider/provider.dart';

import 'package:iparty/providers/users.dart';
import 'package:iparty/widgets/avatar-circles.dart';
import 'package:iparty/widgets/drawer.dart';
import 'package:iparty/widgets/profilepic-picker.dart';

class EditProfileScreen extends StatefulWidget {
  static final routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User _user;
  var _imageUrl = '';
  var _tempUrl = '';
  final _controllerBio = TextEditingController();
  final _controllerGeo = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controllerBio.dispose();
    _controllerGeo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      _searchActiveUser();
    }
    return Scaffold(
      appBar: AppBar(title: Text('Tu perfil')),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Stack(
              children: [
                Container(
                    height: 200,
                    width: 200,
                    child: (_imageUrl == '' && _tempUrl == '')
                        ? MyTextAvatarCircle('H')
                        : MyImageAvatarCircle(
                            _tempUrl == '' ? _imageUrl : _tempUrl,
                            _tempUrl == '')),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: () => _choseImage(context),
                    child: Icon(Icons.photo_camera, color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _controllerBio,
                      decoration: InputDecoration(
                        icon: Icon(Icons.edit),
                        hintText: 'Bio',
                      ),
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 250,
                    ),
                    Stack(
                      children: <Widget>[
                        TextFormField(
                            controller: _controllerGeo,
                            decoration: InputDecoration(
                                icon: Icon(Icons.map), hintText: 'Dirección')),
                        Positioned(
                          child: Icon(Icons.location_searching,
                              color: Theme.of(context).accentColor),
                          right: 0,
                          top: 0,
                          bottom: 0,
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Filtros:',
                                textAlign: TextAlign.left,
                              ),
                              Switch.adaptive(value: true, onChanged: null)
                            ],
                          ),
                        ),
                      ),
                    ),
                    RaisedButton(onPressed: _saveData, child: Text('guardar'))
                  ],
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  _saveData() async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://iparty-goblin-d1e76.appspot.com');

    /// Starts an upload task
    String filePath = 'images/profile/${_user.uid}.jpg';
    final ref = _storage.ref().child(filePath);
    ref.putFile(File(_tempUrl));
    final url = await ref.getDownloadURL() as String;
    try {
      Firestore.instance
          .collection('users')
          .document(_user.uid)
          .updateData({'imageUrl': url, 'bio': _controllerBio.text});
      var provider = Provider.of<UsersProvider>(context, listen: false);
      provider.updateActiveUser(bio: _controllerBio.text, imageUrl: url);
    } on Firestore catch (error) {
      print(error.toString());
    }
  }

  Future<void> _choseImage(BuildContext context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ProfilePicDialog();
      },
    ).then((result) {
      setState(() {
        _tempUrl = result ?? _tempUrl;
      });
    });
  }

  void _searchActiveUser() {
    var provider = Provider.of<UsersProvider>(context, listen: false);
    if (provider != null) {
      _user = provider.activeUser;
    }
    if (_user.imageUrl != null) {
      _imageUrl = _user.imageUrl;
    }
    if (_user.bio != null) {
      _controllerBio.text = _user.bio;
    }
  }
}
