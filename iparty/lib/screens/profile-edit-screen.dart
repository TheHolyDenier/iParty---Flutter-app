import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iparty/providers/users.dart';
import 'package:iparty/widgets/avatar-circles.dart';
import 'package:iparty/widgets/drawer.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static final routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var _imageUrl = '';

  @override
  Widget build(BuildContext context) {
    var activeUser =
        Provider.of<UsersProvider>(context, listen: false).activeUser;
    print(activeUser);
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
                  child: _imageUrl == ''
                      ? MyTextAvatarCircle('H')
                      : MyImageAvatarCircle(_imageUrl),
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
    File image;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Imagen de perfil'),
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  child: image == null
                      ? Container(
                          child: Icon(Icons.photo),
                          color: Theme.of(context).accentColor,
                        )
                      : FittedBox(
                          child: Image.file(image),
                          fit: BoxFit.cover,
                        ),
                  width: 200,
                  height: 200,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Column(
                  children: <Widget>[
                    _imageSelectButton(Icons.photo, 'Desde galería', () {}),
                    _imageSelectButton(
                        Icons.photo_camera,
                        'Desde la cámara',
                        () => setDialogState(() async {
                              image = await _openCamera();
                              print('tata' + image.toString());
                            })),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop(imageUrl);
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget _imageSelectButton(IconData icon, String text, Function function) {
    return SizedBox(
      width: 200,
      child: RaisedButton(
        onPressed: function,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(icon),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  //connect camera
  Future<File> _openCamera() async {
    print('Picker is Called');
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
//    if (img != null) {
//      setState(() {
//        image = img;
//      });
//    }
    return img;
  }
}
