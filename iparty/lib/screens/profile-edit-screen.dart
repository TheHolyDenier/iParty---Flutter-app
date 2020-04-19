import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iparty/widgets/geo-field.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

import '../providers/users.dart';
import '../widgets/avatar-circles.dart';
import '../widgets/drawer.dart';
import '../widgets/profilepic-picker.dart';
import '../widgets/map-dialog.dart';

class EditProfileScreen extends StatefulWidget {
  static final routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

enum ErrorsKm { ok, notNumber, outBounds }
enum StatusUpload { NaN, Uploading, Ok, Error }

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
                    _widgetStatus(),
                    _widgetBio(), // Bio Widget
                    AddressWidget(_controllerGeo, _latLng), // Geo Widget
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
                                _widgetFiltersChips(), // Chips
                                _widgetKm(), // Km
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

  Widget _widgetStatus() {
    return Column(
      children: <Widget>[
        if (_statusUpload == StatusUpload.Error ||
            _statusUpload == StatusUpload.Ok)
          Container(
            child: Text(
              _statusUpload == StatusUpload.Ok
                  ? 'Perfil actualizado.'
                  : 'Ha habido un error',
              style: TextStyle(
                  color: _statusUpload == StatusUpload.Ok
                      ? Colors.green
                      : Theme.of(context).errorColor),
            ),
          ),
        if (_statusUpload == StatusUpload.Uploading)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(width: 5.0),
                Text('Subiendo...'),
              ],
            ),
          )
      ],
    );
  }

  Container _widgetKm() {
    return Container(
      width: double.infinity,
      child: TextField(
        controller: _kmController,
        onChanged: (_) {
          _checkErroKm();
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

  Center _widgetFiltersChips() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        spacing: 10.0,
        runSpacing: 5.0,
        children: <Widget>[
          ChoiceChip(
            label: Text('Online'),
            selected: _online,
            onSelected: (_) {
              setState(() {
                _online = !_online;
              });
            },
          ),
          ChoiceChip(
            label: Text('Rol'),
            selected: _rpg,
            onSelected: (_) {
              setState(() {
                _rpg = !_rpg;
              });
            },
          ),
          ChoiceChip(
            label: Text('Mesa'),
            selected: _tableGames,
            onSelected: (_) {
              setState(() {
                _tableGames = !_tableGames;
              });
            },
          ),
          ChoiceChip(
            label: Text('Espacio seguro'),
            selected: _safeSpace,
            onSelected: (_) {
              setState(() {
                _safeSpace = !_safeSpace;
              });
            },
          ),
        ],
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
    ref.putFile(File(_tempUrl));
    url = await ref.getDownloadURL() as String;
    return url;
  }

//  Fires dialog to chose image, updates tempUrl if needed
  Future<void> _choseImage() async {
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

//  Check if KM is alright
  _checkErroKm() {
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
