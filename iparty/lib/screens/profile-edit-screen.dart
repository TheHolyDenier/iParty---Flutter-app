import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/enums.dart';
import '../providers/users.dart';
import '../widgets/avatar-circles.dart';
import '../widgets/drawer.dart';
import '../widgets/profilepic-picker.dart';
import '../widgets/chips-widget.dart';
import '../widgets/geo-field.dart';
import '../widgets/status-widget.dart';

class EditProfileScreen extends StatefulWidget {
  static final routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

enum ErrorsKm { ok, notNumber, outBounds }

class _EditProfileScreenState extends State<EditProfileScreen> {
  User _user;
  var _imageUrl;
  var _tempUrl = '';

  LatLng _latLng;
  bool _rpg, _tableGames, _safeSpace, _online;
  ErrorsKm _errorsKm = ErrorsKm.ok;
  StatusUpload _statusUpload = StatusUpload.NaN;

  final _controllerBio = TextEditingController();
  final _controllerGeo = TextEditingController();
  final _kmController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controllerBio.dispose();
    _controllerGeo.dispose();
    _kmController.dispose();
    super.dispose();
  }

  _callback(ChipsOptions option, bool newValue) {
    setState(() {
      switch (option) {
        case ChipsOptions.Online:
          _online = newValue;
          break;
        case ChipsOptions.RPG:
          _rpg = newValue;
          break;
        case ChipsOptions.SafeSpace:
          _safeSpace = newValue;
          break;
        case ChipsOptions.TableGames:
          _tableGames = newValue;
          break;
      }
    });
  }

  _callbackGeo(LatLng newValue) {
    setState(() {
      _latLng = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      _searchActiveUser();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu perfil'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: (_errorsKm == ErrorsKm.ok &&
                      _statusUpload != StatusUpload.Uploading)
                  ? _saveData
                  : null),
        ],
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            _widgetProfileImage(),
            Padding(
              padding: EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                child: Column(
                  children: <Widget>[
                    StateWidget(_statusUpload),
                    _widgetBio(),
                    // Bio Widget
                    AddressWidget(
                        controllerGeo: _controllerGeo,
                        latLng: _latLng,
                        callback: _callbackGeo),
                    // Geo Widget
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Filtros:',
                                  textAlign: TextAlign.left,
                                ),
                                ChipsWidget(
                                    online: _online,
                                    rpg: _rpg,
                                    tableGames: _tableGames,
                                    safeSpace: _safeSpace,
                                    callback: _callback),
                                // Chips
                                _widgetKm(),
                                // Km
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  Container _widgetKm() {
    return Container(
      width: double.infinity,
      child: TextField(
        controller: _kmController,
        onChanged: (_) {
          _checkErrorKm();
        },
        decoration: new InputDecoration(
            labelText: 'Distancia máxima de partidas: ',
            suffix: Text('km'),
            errorText: _errorsKm == ErrorsKm.ok
                ? null
                : _errorsKm == ErrorsKm.notNumber
                    ? 'Introduzca un número válido'
                    : 'La distancia mínima es 0km'),
        keyboardType: TextInputType.numberWithOptions(),
      ),
    );
  }

  TextFormField _widgetBio() {
    return TextFormField(
      controller: _controllerBio,
      decoration: InputDecoration(
        icon: Icon(Icons.edit),
        labelText: 'Sobre ti',
//                        suffix: Text('${_controllerBio.text.length ?? 0}/250'),
      ),
      maxLines: 1,
      textInputAction: TextInputAction.done,
      maxLength: 250,
    );
  }

  Stack _widgetProfileImage() {
    return Stack(
      children: [
        Container(
            height: 200,
            width: 200,
            child: (_imageUrl == '' && _tempUrl == '')
                ? MyTextAvatarCircle(_user.displayName[0].toUpperCase())
                : MyImageAvatarCircle(
                    _tempUrl == '' ? _imageUrl : _tempUrl, _tempUrl == '')),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () => _choseImage(),
            child: Icon(Icons.photo_camera, color: Colors.white),
          ),
        ),
      ],
    );
  }

  _saveData() async {
    setState(() {
      _statusUpload = StatusUpload.Uploading;
    });
    var url;
    if (_tempUrl != '') {
      url = await _uploadImage(url);
    } else {
      url = _imageUrl;
    }

//    try {
//      Updates Firebase
    Firestore.instance.collection('users').document(_user.uid).updateData({
      'imageUrl': url,
      'bio': _controllerBio.text,
      'latitude': _latLng.latitude.toString(),
      'longitude': _latLng.longitude.toString(),
      'km': _kmController.text.toString(),
      'rpg': _rpg ? '1' : '0',
      'table': _tableGames ? '1' : '0',
      'safe': _safeSpace ? '1' : '0',
      'online': _online ? '1' : '0',
    }).then((_) {
//      Updates User provider
      _updateProvider(url);
//      Sets ok message
      setState(() {
        _statusUpload = StatusUpload.Ok;
      });
    }).catchError((error) {
//    } on StorageError catch (error) {
      // Not ok
      setState(() {
        _statusUpload = StatusUpload.Error;
      });
      print(error.toString());
    });
  }

  void _updateProvider(url) {
    var provider = Provider.of<UsersProvider>(context, listen: false);
    provider.updateActiveUser(
        bio: _controllerBio.text ?? '',
        imageUrl: url ?? '',
        km: _kmController.text != null
            ? double.parse(_kmController.text) >= 1.0
                ? double.parse(_kmController.text)
                : 0.0
            : 0.0,
        latLng: _latLng,
        online: _online,
        rpg: _rpg,
        safe: _safeSpace,
        table: _tableGames);
  }

  Future _uploadImage(url) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://iparty-goblin-d1e76.appspot.com');

    // Starts an upload task
    String filePath = 'images/profile/${_user.uid}.jpg';
    final ref = _storage.ref().child(filePath);
    final StorageUploadTask uploadTask = ref.putFile(File(_tempUrl));
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }

//  Fires dialog to chose image, updates tempUrl if needed
  void _choseImage() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PicDialog();
      },
    ).then((result) {
      setState(() {
        _tempUrl = result ?? _tempUrl;
      });
    });
  }

//  Checks if KM is alright
  _checkErrorKm() {
    if (_kmController.text.isEmpty) {
      _errorsKm = ErrorsKm.ok;
    } else if (double.tryParse(_kmController.text) == null) {
      _errorsKm = ErrorsKm.notNumber;
    } else if (double.parse(_kmController.text) < 0) {
      _errorsKm = ErrorsKm.outBounds;
    } else {
      _errorsKm = ErrorsKm.ok;
    }
  }

//  Search in User's provider for active user and update fields with that data if exists
  void _searchActiveUser() {
    var provider = Provider.of<UsersProvider>(context, listen: false);
    setState(() {
      if (provider != null) {
        _user = provider.activeUser;
      }
      _imageUrl = _user.imageUrl ?? '';
      _controllerBio.text = _user.bio ?? '';
      _latLng = LatLng(_user.latitude, _user.longitude);
//      _searchAddress();
      _rpg = _user.rpg ?? true;
      _tableGames = _user.table ?? true;
      _safeSpace = _user.safe ?? true;
      _kmController.text = _user.km.toString() ?? '0.0';
      _online = _user.online ?? true;
    });
  }
}
