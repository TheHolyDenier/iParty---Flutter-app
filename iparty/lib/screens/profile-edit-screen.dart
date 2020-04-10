import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

class _EditProfileScreenState extends State<EditProfileScreen> {
  User _user;
  var _imageUrl = '';
  var _tempUrl = '';
  final _controllerBio = TextEditingController();
  final _controllerGeo = TextEditingController();
  final _kmController = TextEditingController();
  LatLng _latLng;
  bool _rpg = true;
  bool _tableGames = true;
  bool _safeSpace = true;
  ErrorsKm _errorsKm = ErrorsKm.ok;

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
                        ? MyTextAvatarCircle(_user.displayName[0].toUpperCase())
                        : MyImageAvatarCircle(
                            _tempUrl == '' ? _imageUrl : _tempUrl,
                            _tempUrl == '')),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: () => _choseImage(),
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
//                        suffix: Text('${_controllerBio.text.length ?? 0}/250'),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      maxLength: 250,
                    ),
                    Stack(
                      children: <Widget>[
                        TextFormField(
                            enabled: false,
                            controller: _controllerGeo,
                            decoration: InputDecoration(
                                icon: Icon(Icons.map), hintText: 'Dirección')),
                        Positioned(
                          child: IconButton(
                            icon: Icon(Icons.location_searching,
                                color: Theme.of(context).accentColor),
                            onPressed: _setLocation,
                          ),
                          right: 0,
                          top: 0,
                          bottom: 0,
                        ),
                      ],
                    ),
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
                                Center(
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    alignment: WrapAlignment.center,
                                    spacing: 20.0,
                                    children: <Widget>[
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
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: _kmController,
                                    onChanged: (_) {
                                      _checkErroKm();
                                    },
                                    decoration: new InputDecoration(
                                        suffix: Text('km'),
                                        errorText: _errorsKm == ErrorsKm.ok
                                            ? null
                                            : _errorsKm == ErrorsKm.notNumber
                                                ? 'Introduzca un número válido'
                                                : 'La distancia mínima es 1km'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    RaisedButton(
                        onPressed: _errorsKm == ErrorsKm.ok ? _saveData : null,
                        child: Text('guardar'))
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
      Firestore.instance.collection('users').document(_user.uid).updateData({
        'imageUrl': url,
        'bio': _controllerBio.text,
        'latitude': _latLng.latitude.toString(),
        'longitude': _latLng.longitude.toString(),
        'km': _kmController.text.toString(),
        'rpg': _rpg ? '1' : '0',
        'table': _tableGames ? '1' : '0',
        'safe': _safeSpace ? '1' : '0',
      });
      var provider = Provider.of<UsersProvider>(context, listen: false);
      provider.updateActiveUser(bio: _controllerBio.text, imageUrl: url);
    } on Firestore catch (error) {
      print(error.toString());
    }
  }

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

  _checkErroKm() {
    if (_kmController.text.isEmpty) {
      _errorsKm = ErrorsKm.ok;
    } else if (double.tryParse(_kmController.text) == null) {
      _errorsKm = ErrorsKm.notNumber;
    } else if (double.parse(_kmController.text) < 1) {
      _errorsKm = ErrorsKm.outBounds;
    } else {
      _errorsKm = ErrorsKm.ok;
    }
  }

  Future<void> _setLocation() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return MapDialog();
      },
    ).then((result) async {
      if (result != null) {
        _latLng = LatLng(double.parse(result.split('_')[0]),
            double.parse(result.split('_')[1]));
        _searchAddress();
      }
    });
  }

  _searchAddress() async {
    await Geolocator()
        .placemarkFromCoordinates(_latLng.latitude, _latLng.longitude)
        .then((address) {
      _controllerGeo.text =
          '${address[0].thoroughfare} ${address[0].name}, ${address[0].locality}';
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
    if (_user.latitude != null) {
      _latLng = LatLng(_user.latitude, _user.longitude);
      _searchAddress();
    }
  }
}
