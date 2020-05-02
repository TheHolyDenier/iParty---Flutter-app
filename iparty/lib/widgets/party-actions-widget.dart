import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:iparty/models/party.dart';
import 'package:iparty/screens/joined-parties-screen.dart';
import 'package:iparty/widgets/dialog-sure-widget.dart';

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

  _PartyActionsWidgetState(this._party, this._callback);

  @override
  Widget build(BuildContext context) {
    _genList(Theme.of(context));
    return FabDialer(_fabMiniMenuItemList, Theme.of(context).accentColor,
        new Icon(Icons.settings));
  }

  void _genList(ThemeData themeData) {
    var background = themeData.accentColor;
    _fabMiniMenuItemList = [
      FabMiniMenuItem.withText(
          new Icon(Icons.delete),
          background,
          4.0,
          '',
          _finishCampaign,
          'Finalizar partida',
          Colors.white,
          Colors.black,
          true),
      FabMiniMenuItem.withText(new Icon(Icons.add_photo_alternate), background,
          4.0, '', () {}, 'Cambiar portada', Colors.white, Colors.black, true),
      FabMiniMenuItem.withText(new Icon(Icons.person_add), background, 4.0, '',
          () {}, 'Añadir jugador', Colors.white, Colors.black, true),
      FabMiniMenuItem.withText(new Icon(Icons.not_interested), background, 4.0,
          '', () {}, 'Eliminar jugador', Colors.white, Colors.black, true),
    ];
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
