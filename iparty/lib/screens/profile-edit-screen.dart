import 'dart:io';

import 'package:flutter/material.dart';

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
  var _imageUrl = '';
  var _tempUrl = '';

  @override
  Widget build(BuildContext context) {
    var activeUser =
        Provider.of<UsersProvider>(context, listen: false).activeUser;
    print(activeUser); // Instance of user
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
                            _tempUrl == '')
                    //  activeUser.imageUrl.isEmpty
                    //     ? MyTextAvatarCircle(activeUser.displayName[0])
                    //     : MyImageAvatarCircle(activeUser.imageUrl),
                    ),
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
                    RaisedButton(onPressed: () {}, child: Text('guardar'))
                  ],
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  Future<String> _choseImage(BuildContext context) async {
    String imageUrl = '';
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return ProfilePicDialog();
      },
    );
    print(result.toString());
    setState(() {
      _tempUrl = result.toString();
    });
    return imageUrl;
  }
}
