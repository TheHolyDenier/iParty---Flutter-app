import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';

class PartyActionsWidget extends StatefulWidget {
  @override
  _PartyActionsWidgetState createState() => _PartyActionsWidgetState();
}

class _PartyActionsWidgetState extends State<PartyActionsWidget> {
  List<FabMiniMenuItem> _fabMiniMenuItemList;


  @override
  Widget build(BuildContext context) {
    _genList(Theme.of(context));
    return FabDialer(
        _fabMiniMenuItemList, Theme.of(context).accentColor, new Icon(Icons.settings));
  }

  void _genList(ThemeData themeData) {
    var background = themeData.accentColor;
    _fabMiniMenuItemList = [
      FabMiniMenuItem.withText(
          new Icon(Icons.delete),
          background,
          4.0,
          '',
          () {},
          'Finalizar partida',
          Colors.white,
          Colors.black,
          true),
      FabMiniMenuItem.withText(
          new Icon(Icons.add_photo_alternate),
          background,
          4.0,
          '',
          () {},
          'Cambiar portada',
          Colors.white,
          Colors.black,
          true),
      FabMiniMenuItem.withText(
          new Icon(Icons.person_add),
          background,
          4.0,
          '',
          () {},
          'Añadir jugador',
          Colors.white,
          Colors.black,
          true),
      FabMiniMenuItem.withText(
          new Icon(Icons.not_interested),
          background,
          4.0,
          '',
          () {},
          'Eliminar jugador',
          Colors.white,
          Colors.black,
          true),
    ];
  }
}
