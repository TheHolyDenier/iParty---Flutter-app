import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import '../models/party.dart';
import '../providers/users.dart';
import '../models/user.dart';

class PartyDetailsWidget extends StatefulWidget {
  final Party _party;

  PartyDetailsWidget(this._party);

  @override
  _PartyDetailsWidgetState createState() => _PartyDetailsWidgetState(_party);
}

class _PartyDetailsWidgetState extends State<PartyDetailsWidget> {
  final Party _party;

  _PartyDetailsWidgetState(this._party);

  var _dayFormat = new DateFormat('dd-MM-yy');
  var _timeFormat = new DateFormat.Hm();

  UsersProvider _provider;
  User _user;
  bool _needInit = true;
  double _km;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = _party.date;
    if (_needInit) {
      _provider = Provider.of<UsersProvider>(context);
      setState(() {
        _user = _provider.activeUser;
      });
    }
    _needInit = false;
    return Container(
      width: double.infinity,
      child: Row(
        children: <Widget>[
          _party.isOnline
              ? Expanded(
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.web_asset),
                      Container(
                          child: Text(
                        _party.isOnline &&
                                Uri.parse(_party.headquarter).isAbsolute
                            ? Uri.parse(_party.headquarter).host.split('.')[1]
                            : _party.headquarter,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      )),
                    ],
                  ),
                )
              : _getDistanceWidget(context),
          _numberPlayersWidget(),
          Expanded(
            child: Column(
              children: <Widget>[
                Icon(Icons.timer),
                Text('${_timeFormat.format(dateTime)}'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Icon(Icons.calendar_today),
                Text('${_dayFormat.format(dateTime)}')
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column _numberPlayersWidget() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.supervised_user_circle),
              SizedBox(width: 5),
              Column(
                children: <Widget>[
                  Text(
                      '${_party.players['min'].toStringAsFixed(0)} - ${_party.players['max'].toStringAsFixed(0)}'),
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
        )
      ],
    );
  }

  Widget _getDistanceWidget(BuildContext context) {
    if (!_provider.userGot || _provider.activeUser?.latitude != null)
      _getPlace();
    else if (_provider.activeUser?.latitude != null) {
      print('entra');
    }
    return Column(
      children: <Widget>[
        Icon(Icons.location_on),
        Container(
            width: 75.0,
            child: Center(
              child: Text(
                (_provider.userGot)
                    ? _provider.activeUser?.latitude != null
                        ? '${Distance().as(LengthUnit.Kilometer, LatLng(_provider.activeUser?.latitude, _provider.activeUser?.longitude), LatLng(_party.getLatLong().latitude, _party.getLatLong().longitude))} km'
                        : '$_city'
                    : '$_city',
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }

  String _city = '';

  void _getPlace() async {
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        _party.getLatLong().latitude, _party.getLatLong().longitude);

    setState(() {
      _city = placemark[0].locality; // update _address
    });
  }
}
