import 'package:flutter/material.dart';

enum ChipsOptions { Online, RPG, TableGames, SafeSpace }

class ChipsWidget extends StatefulWidget {
  final bool online, rpg, tableGames, safeSpace;
  final Function callback;
  final bool filter;

  ChipsWidget(
      {this.online = false,
      this.rpg = false,
      this.tableGames = false,
      this.safeSpace = false,
      this.callback,
      this.filter = true});

  @override
  _ChipsWidgetState createState() => _ChipsWidgetState(
      online, rpg, tableGames, safeSpace, callback, filter);
}

class _ChipsWidgetState extends State<ChipsWidget> {
  bool _online, _rpg, _tableGames, _safeSpace;
  Function _callback;
  final bool filter;

  _ChipsWidgetState(this._online, this._rpg, this._tableGames, this._safeSpace,
      this._callback, this.filter);

  @override
  Widget build(BuildContext context) {
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
                _callback(ChipsOptions.Online, _online);
              });
            },
          ),
          if (filter)
            ChoiceChip(
              label: Text('Rol'),
              selected: _rpg,
              onSelected: (_) {
                setState(() {
                  _rpg = !_rpg;
                  _callback(ChipsOptions.RPG, _rpg);
                });
              },
            ),
          if (filter)
            ChoiceChip(
              label: Text('Mesa'),
              selected: _tableGames,
              onSelected: (_) {
                setState(() {
                  _tableGames = !_tableGames;
                  _callback(ChipsOptions.TableGames, _tableGames);
                });
              },
            ),
          ChoiceChip(
            label: Text('Espacio seguro'),
            selected: _safeSpace,
            onSelected: (_) {
              setState(() {
                _safeSpace = !_safeSpace;
                _callback(ChipsOptions.SafeSpace, _safeSpace);
              });
            },
          ),
        ],
      ),
    );
  }
}
