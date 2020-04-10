import 'dart:async';
import 'dart:ui' as ui;

import 'package:image/image.dart' as Img;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

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
                  ? Text('Seleccione una imagen...')
                  : Container(
                      width: 200,
                      height: 200,
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
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.jpg,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      maxWidth: 350,
      maxHeight: 350,
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Recortar foto de perfil',
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
