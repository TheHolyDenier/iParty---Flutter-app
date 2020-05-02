import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iparty/models/user.dart';
import 'package:iparty/widgets/delete-user-dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../models/party.dart';
import '../screens/joined-parties-screen.dart';
import '../widgets/dialog-sure-widget.dart';
import '../widgets/profilepic-picker.dart';

class PartyActionsWidget extends StatefulWidget {
  final Party party;
  final Function callback;
  final Map<String, User> listUsers;

  PartyActionsWidget(this.party, this.callback, this.listUsers);

  @override
  _PartyActionsWidgetState createState() =>
      _PartyActionsWidgetState(party, callback, listUsers);
}

class _PartyActionsWidgetState extends State<PartyActionsWidget> {
  List<FabMiniMenuItem> _fabMiniMenuItemList;
  var _db = Firestore.instance;
  Party _party;
  Function _callback;
  String _tempUrl;
  ProgressDialog _progressDialog;
  Map<String, User> _listUsers;
  ThemeData _themeData;

  _PartyActionsWidgetState(this._party, this._callback, this._listUsers);

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    _genList();
    return FabDialer(_fabMiniMenuItemList, Theme.of(context).accentColor,
        new Icon(Icons.settings));
  }

  void _genList() {
    var background = _themeData.accentColor;
    _fabMiniMenuItemList = [];
    if (_party.isCampaign && _party.date.isBefore(DateTime.now()))
      _fabMiniMenuItemList.add(FabMiniMenuItem.withText(
          new Icon(Icons.delete),
          background,
          4.0,
          '',
          _finishCampaign,
          'Finalizar partida',
          Colors.white,
          Colors.black,
          true));
    _fabMiniMenuItemList.add(FabMiniMenuItem.withText(
        new Icon(Icons.add_photo_alternate),
        background,
        4.0,
        '',
        _choseImage,
        'Cambiar portada',
        Colors.white,
        Colors.black,
        true));
    _fabMiniMenuItemList.add(FabMiniMenuItem.withText(
        new Icon(Icons.person_add),
        background,
        4.0,
        '',
        () {},
        'Añadir jugador',
        Colors.white,
        Colors.black,
        true));
      _fabMiniMenuItemList.add(FabMiniMenuItem.withText(
          new Icon(Icons.not_interested),
          background,
          4.0,
          '',
          _deletePlayer,
          'Eliminar jugador',
          Colors.white,
          Colors.black,
          true));
  }

  void _addPlayer() {}

  void _deletePlayer() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DialogDeleteUser(_listUsers, _party.uid, _updateUsers);
      },
    );
  }

  _updateUsers(Map<String, User> listUsers) {
    List<String> keys = List();
    setState(() {
      _listUsers = listUsers;
      _listUsers.forEach((key, value) => keys.add(key));
      _party.playersUID = keys;
      _callback(_party);
    });
  }

//  CHOSES NEW COVER
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
      _savePic();
    });
  }

//   UPLOADS IMAGE AND SAVES URL
  Future _uploadImage(url) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://iparty-goblin-d1e76.appspot.com');

    // Starts an upload task
    String filePath = 'images/party/${_party.uid}.jpg';
    final ref = _storage.ref().child(filePath);
    final StorageUploadTask uploadTask = ref.putFile(File(_tempUrl));
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }

//  UPDATE PICTURE IN OBJECT
  _savePic() async {
    _setProgressDialog();
    _progressDialog.show(); // SHOWS DIALOG
    var url;
    if (_tempUrl != '') {
      url = await _uploadImage(url);
    } else {
      url = '';
    }
//      Updates Firebase
    Firestore.instance.collection('parties').document(_party.uid).updateData({
      'imageUrl': url,
    }).then((_) {
//      Sets ok message
      setState(() {
        _party.imageUrl = url;
      });
      _callback(_party);
      _progressDialog.hide(); // HIDES MESSAGE
    }).catchError((error) {
      print(error.toString());
      _progressDialog.hide(); // HIDES MESSAGE
    });
  }

//  SETS OPTIONS DIALOG
  void _setProgressDialog() {
    _progressDialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    _progressDialog.style(
      message: 'Se está guardando su nueva portada',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitWanderingCubes(
        color: Theme.of(context).primaryColor,
        size: 20.0,
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
    );
  }

//  CLOSES CAMPAIGN
  void _finishCampaign() {
    showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DialogSureWidget('Finalizar camapaña',
            'Va a marcar su partida como finalizada. No podrá acceder a ella ni a su chat y desaparecerá del índice de sus jugadores. Asegúrese de que tiene todo lo que necesita.');
      },
    ).then((value) {
      if (value == 1) {
        _db
            .collection('parties')
            .document(_party.uid)
            .updateData({'isFinished': '1'}).then((_) {
          setState(() {
            _party.isFinished = true;
          });
          _callback(_party);
          Navigator.of(context).pushReplacementNamed(PartiesScreen.routeName);
        });
      }
    });
  }
}
