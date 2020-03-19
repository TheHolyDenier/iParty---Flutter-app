import 'package:flutter/material.dart';
import 'package:iparty/models/party.dart';

class PartyDetailsWidget extends StatelessWidget {
  final Party _party;
  PartyDetailsWidget(this._party);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(Icons.location_on),
        Text(_party.headquarter),
        SizedBox(width: 5),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.supervised_user_circle),
              SizedBox(width: 5),
              Column(
                children: <Widget>[
                  Text('${_party.players['min']} - ${_party.players['max']}'),
                  Text(
                    'Jugadores',
                    style: TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                        height: 1),
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(width: 5),
        Icon(Icons.timer),
        Text('16:45'),
        SizedBox(width: 5),
        Icon(Icons.calendar_today),
        Text('${_party.date}'),
      ],
    );
  }
}
