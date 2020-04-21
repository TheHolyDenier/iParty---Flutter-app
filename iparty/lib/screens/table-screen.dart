import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums.dart';
import '../widgets/chips-widget.dart';
import '../widgets/geo-field.dart';
import '../widgets/profilepic-picker.dart';
import '../widgets/status-widget.dart';
import '../providers/users.dart';

class NewTableScreen extends StatefulWidget {
  static final routeName = '/new-table';

  @override
  _NewTableScreenState createState() => _NewTableScreenState();
}

class _NewTableScreenState extends State<NewTableScreen> {
  bool _game = false, _length = false, _safeSpace = false, _online = false;
  var _partyUI = Uuid().v4();
  LatLng _latLng;
  var _numberPlayers = RangeValues(2, 5);
  DateTime selectedDate;
  TimeOfDay selectedTime;
  var formatter = new DateFormat('dd-MM-yyyy');
  var customError = {'address': false, 'dateTime': false};
  var _tempUrl = '';
  StatusUpload _statusUpload = StatusUpload.NaN;
  String _userUid;

  final _form = GlobalKey<FormState>();

  final _controllerGeo = TextEditingController();
  final _controllerPartyName = TextEditingController();
  final _controllerWebsite = TextEditingController();
  final _controllerSummary = TextEditingController();
  final _controllerGame = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controllerGeo.dispose();
    _controllerPartyName.dispose();
    _controllerWebsite.dispose();
    _controllerSummary.dispose();
    _controllerGame.dispose();
  }

  void _callback(ChipsOptions option, bool newValue) {
    setState(() {
      switch (option) {
        case ChipsOptions.Online:
          _online = newValue;
          break;
        case ChipsOptions.SafeSpace:
          _safeSpace = newValue;
          break;
        default:
          break;
      }
    });
  }

  void _callbackGeo(LatLng newValue) {
    setState(() {
      _latLng = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<UsersProvider>(context, listen: false);
    _userUid = provider.activeUser.uid;
    return Scaffold(
      appBar: AppBar(
        // TITLE
        title: Text('Nueva mesa'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _statusUpload != StatusUpload.Uploading
                ? () {
                    if (_form.currentState.validate() && _checkEverything()) {
                      _saveData();
                    }
                  }
                : null,
          )
        ],
      ),
      body: SingleChildScrollView(
        // BODY
        child: Column(
          children: <Widget>[
            _picCoverWidget(),
            // PARTY'S COVER
            StateWidget(_statusUpload),
            // SETTED IF UPLOADING IS IN PROGRESS/ OK / ERROR
            Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Rellene la siguiente información para crear su actividad: '),
                    ),
                    _basicInfoWidget(), // GETS NEEDED INFO
                    const SizedBox(
                      height: 10.0,
                    ),
                    _additionalInfoWidget(), // GETS EXTRA INFO
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _checkEverything() {
    var everythingAlright = true;
    setState(() {
      customError['address'] = false;
      customError['dateTime'] = false;
    });
    if (!_online && _latLng == null) {
      setState(() {
        everythingAlright = false;
        customError['address'] = true;
      });
    }
    if (selectedDate == null || selectedTime == null) {
      setState(() {
        everythingAlright = false;
        customError['dateTime'] = true;
      });
    }

    return everythingAlright;
  }

  Widget _picCoverWidget() {
    // SETS IMAGE IF SELECTED,
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width / 16 * 9,
      color: Theme.of(context).accentColor,
      child: GestureDetector(
        // SHOTS PIC CHOOSE DIALOG
        onTap: _choseImage,
        child: FittedBox(
          // ALTERNATES BETWEEN ICON AND IMAGE, IF CHOOSE
          fit: _tempUrl == '' ? BoxFit.contain : BoxFit.cover,
          child: _tempUrl == ''
              ? Icon(Icons.photo)
              : Image(
                  image: AssetImage(_tempUrl),
                ),
        ),
      ),
    );
  }

  Widget _additionalInfoWidget() {
    // ASKS ADDITIONAL INFO
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text('Información adicional',
                style: Theme.of(context).textTheme.headline5),
            TextFormField(
              controller: _controllerGame,
              maxLength: 100,
              decoration: InputDecoration(
                  labelText: 'Juego', hintText: '¿A qué vais a jugar?'),
            ),
            TextFormField(
              controller: _controllerSummary,
              maxLines: 5,
              minLines: 1,
              maxLength: 500,
              decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Cuenta a tus jugadores qué vais a hacer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicInfoWidget() {
    // GETS ALL INFO YOU NEED TO START A PARTY
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text('Información de la partida',
                style: Theme.of(context).textTheme.headline5),
            TextFormField(
              controller: _controllerPartyName,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Este campo no puede estar vacío';
                }
                if (value.length < 3) {
                  return 'Un nombre válido necesita al menos 3 caracteres';
                }
                return null;
              },
              maxLength: 100,
              decoration: InputDecoration(
                  labelText: 'Nombre de la mesa',
                  hintText: 'Servirá para que otros usuarios la reconozcan'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ChipsWidget(
                  online: _online,
                  safeSpace: _safeSpace,
                  callback: _callback,
                  filter: false),
            ),
            _typeOfGameWidget(), // RPG OR BOARDGAME
            _numberOfSessionsWidget(), // ONESHOT OR CAMPAIGN
            _numberOfPlayersWidget(), // RANGE OF PLAYERS
            _online // SWITCHES BETWEEN LOCATION OR INPUTTEXTFIELD
                ? Container(
                    child: TextFormField(
                      controller: _controllerWebsite,
                      validator: (value) {
                        if (_online && value.isEmpty) {
                          return 'Seleccione el medio de encuentro';
                        }
                        return null;
                      },
                      maxLength: 250,
                      decoration: InputDecoration(
                        labelText: 'Medio de encuentro',
                        hintText:
                            'Ej. Telegram, Tabletop Simulator, link de la partida...',
                        icon: Icon(Icons.web),
                      ),
                    ),
                  )
                : AddressWidget(
                    controllerGeo: _controllerGeo,
//                    latLng: LatLng(40.974737, -5.672455),
                    callback: _callbackGeo),
            if (customError['address'])
              Container(
                width: double.infinity,
                child: Text(
                  'Seleccione lugar de encuentro',
                  style: TextStyle(
                      color: Theme.of(context).errorColor, fontSize: 12),
                ),
              ),
            _dateTimeWidget(),
            if (customError['dateTime'])
              Container(
                width: double.infinity,
                child: Text(
                  'Seleccione fecha y hora',
                  style: TextStyle(
                      color: Theme.of(context).errorColor, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Fecha y hora:'),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            if (selectedDate != null) Text('${formatter.format(selectedDate)}'),
            IconButton(
              onPressed: () => _selectDate(),
              icon: Icon(Icons.calendar_today,
                  color: Theme.of(context).accentColor),
            ),
            if (selectedTime != null) Text('${selectedTime.format(context)}'),
            IconButton(
              onPressed: () => _selectedTime(),
              icon:
                  Icon(Icons.access_time, color: Theme.of(context).accentColor),
            ),
          ],
        )
      ],
    );
  }

  Widget _numberOfPlayersWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Jugadores:'),
        Expanded(
          child: RangeSlider(
            values: _numberPlayers,
            min: 1,
            max: 10,
            onChanged: (RangeValues values) {
              setState(() {
                _numberPlayers = values;
              });
            },
            divisions: 9,
            labels: RangeLabels('${_numberPlayers.start.round()}',
                '${_numberPlayers.end.round()}'),
          ),
        ),
      ],
    );
  }

  Widget _numberOfSessionsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Sesiones:'),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Container(
                width: 50.0,
                child: Text(
                  'única',
                  textAlign: TextAlign.right,
                )),
            Switch(
                value: _length,
                onChanged: (bool value) {
                  setState(() {
                    _length = value;
                  });
                }),
            Container(width: 50.0, child: Text('varias')),
          ],
        ),
      ],
    );
  }

  Widget _typeOfGameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Juego de:'),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Container(
                width: 50.0,
                child: Text(
                  'mesa',
                  textAlign: TextAlign.right,
                )),
            Switch(
                value: _game,
                onChanged: (bool value) {
                  setState(() {
                    _game = value;
                  });
                }),
            Container(width: 50.0, child: Text('rol')),
          ],
        ),
      ],
    );
  }

  void _selectDate() async {
    var now = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime(now.year, now.month, now.day + 1),
        firstDate: new DateTime(now.year, now.month, now.day + 1),
        lastDate: new DateTime(now.year, now.month + 3, now.day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _selectedTime() async {
    final picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  //  Fires dialog to chose image, updates tempUrl if needed
  void _choseImage() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PicDialog(
          profilePic: false,
        );
      },
    ).then((result) {
      setState(() {
        _tempUrl = result ?? _tempUrl;
      });
    });
  }

  _saveData() async {
    setState(() {
      _statusUpload = StatusUpload.Uploading;
    });
    var url;
    if (_tempUrl != '') {
      url = await _uploadImage(url);
    } else {
      url = '';
    }
    DateTime dateTime = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, selectedTime.hour, selectedTime.minute);
//      Updates Firebase
    Firestore.instance.collection('parties').document(_partyUI).setData({
      'title': _controllerPartyName.text,
      'game': _controllerGame.text ?? '',
      'imageUrl': url,
      'summary': _controllerSummary.text ?? '',
      'players': {'min': _numberPlayers.start, 'max': _numberPlayers.end},
      'playersUID': ['$_userUid'],
      'isRpg': _game ? '1' : '0',
      'isCampaign': _length ? '1' : '0',
      'isOnline': _online ? '1' : '0',
      'isSafe': _safeSpace ? '1' : '0',
      'headquarter': _online
          ? _controllerWebsite.text
          : '${_latLng.latitude}_${_latLng.longitude}',
      'date': dateTime,
    }).then((_) {
//      Sets ok message
      setState(() {
        _statusUpload = StatusUpload.Ok;
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      // Not ok
      setState(() {
        _statusUpload = StatusUpload.Error;
      });
      print(error.toString());
    });
  }

  Future _uploadImage(url) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://iparty-goblin-d1e76.appspot.com');

    // Starts an upload task
    String filePath = 'images/party/$_partyUI.jpg';
    final ref = _storage.ref().child(filePath);
    final StorageUploadTask uploadTask = ref.putFile(File(_tempUrl));
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }
}
