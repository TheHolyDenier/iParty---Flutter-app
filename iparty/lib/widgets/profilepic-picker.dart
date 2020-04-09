import 'package:image/image.dart' as Img;
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ProfilePicDialog extends StatefulWidget {
  @override
  _ProfilePicDialog createState() => _ProfilePicDialog();
}

class _ProfilePicDialog extends State<ProfilePicDialog> {
  File _image;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Imagen de perfil'),
      content: SingleChildScrollView(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              child: _image == null
                  ? Container(
                      child: Icon(Icons.photo),
                      color: Theme.of(context).accentColor,
                    )
                  : FittedBox(
                      child: Image.file(_image),
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
                _imageSelectButton(
                    Icons.photo, 'Desde galería', ImageSource.gallery),
                _imageSelectButton(
                    Icons.photo_camera, 'Desde la cámara', ImageSource.camera)
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop()),
        FlatButton(
            child: Text('Guardar'),
            onPressed: () => Navigator.pop(context, _image.uri.toFilePath())),
      ],
    );
  }

  Widget _imageSelectButton(
      IconData icon, String text, ImageSource imageSource) {
    return SizedBox(
      width: 200,
      child: RaisedButton(
        onPressed: () => _openCamera(imageSource),
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

  _openCamera(ImageSource imageSource) async {
    File img = await ImagePicker.pickImage(source: imageSource);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }
}
