import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';

class PicDialog extends StatefulWidget {
  final profilePic;

  PicDialog({this.profilePic = true});

  @override
  _ProfilePicDialog createState() => _ProfilePicDialog(profilePic);
}

class _ProfilePicDialog extends State<PicDialog> {
  final _profilePic;

  _ProfilePicDialog(this._profilePic);

  File _image;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_profilePic ? 'Imagen de perfil' : 'Portada de la partida'),
      content: SingleChildScrollView(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              child: _image == null
                  ? Text('Seleccione una imagen...')
                  : Container(
                      width: 200,
                      height: 125,
                      child: FittedBox(
                        child: Image.file(_image),
                        fit: BoxFit.cover,
                      ),
                    ),
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
          onPressed: _image != null ? _cropImage : null,
        ),
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

  Future<void> _cropImage() async {
    await ImageCropper.cropImage(
      sourcePath: _image.path,
      cropStyle: CropStyle.rectangle,
      compressFormat: ImageCompressFormat.jpg,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio16x9,
      ],
      maxWidth: 600,
      maxHeight: 340,
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: _profilePic
              ? 'Recortar foto de perfil'
              : 'Recortar portada de tu partdia',
          toolbarColor: Theme.of(context).accentColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true),
    ).then((cropped) {
      if (cropped != null) {
        setState(() {
          _image = cropped ?? _image;
        });
        String path = _image.uri.toFilePath();
        Navigator.pop(context, path);
      }
    });
  }
}
