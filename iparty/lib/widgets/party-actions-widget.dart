import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';

import 'package:iparty/models/party.dart';
import 'package:iparty/screens/joined-parties-screen.dart';
import 'package:iparty/widgets/dialog-sure-widget.dart';
import 'package:iparty/widgets/profilepic-picker.dart';
import 'package:iparty/widgets/uploading-dialog.dart';

class PartyActionsWidget extends StatefulWidget {
  final Party party;
  final Function callback;

  PartyActionsWidget(this.party, this.callback);

  @override
  _PartyActionsWidgetState createState() =>
      _PartyActionsWidgetState(party, callback);
}

class _PartyActionsWidgetState extends State<PartyActionsWidget> {
  List<FabMiniMenuItem> _fabMiniMenuItemList;
  var _db = Firestore.instance;
  Party _party;
  Function _callback;
  String _tempUrl;
  bool _closeDialog = false;

  _PartyActionsWidgetState(this._party, this._callback);

  @override
  Widget build(BuildContext context) {
    _genList(Theme.of(context));
    return FabDialer(_fabMiniMenuItemList, Theme.of(context).accentColor,
        new Icon(Icons.settings));
  }

  void _genList(ThemeData themeData) {
    var background = themeData.accentColor;
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
        () {},
        'Eliminar jugador',
        Colors.white,
        Colors.black,
        true));
  }

  void _addPlayer() {}

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

  _savePic() async {
    setState(() {
      _closeDialog = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UploadingDialog(_closeDialog),
    );
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
      setState(() {
        _closeDialog = true;
      });
    }).catchError((error) {
      print(error.toString());
      setState(() {
        _closeDialog = true;
      });
    });
  }

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

//  void _joinParty() {
//    _party.playersUID.add('${_provider.activeUser.uid}');
//    Firestore.instance.collection('parties').document(_party.uid).updateData({
//      'playersUID': _party.playersUID,
//    }).then((_) {
////      Sets ok message
//      setState(() {
//        _statusJoin = StatusJoin.Ok;
//      });
//    }).catchError((error) {
//      // Not ok
//      setState(() {
//        _statusJoin = StatusJoin.Error;
//      });
//      print(error.toString());
//    });
//  }
}
