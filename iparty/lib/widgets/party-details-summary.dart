import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:iparty/models/user.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import '../models/party.dart';
import '../providers/users.dart';

class PartyDetailsWidget extends StatefulWidget {
  final Party _party;

  PartyDetailsWidget(this._party);

  @override
  _PartyDetailsWidgetState createState() => _PartyDetailsWidgetState(_party);
}

class _PartyDetailsWidgetState extends State<PartyDetailsWidget> {
  final Party _party;

  _PartyDetailsWidgetState(this._party);

  var _dayFormat = new DateFormat('dd-MM-yyyy');

  var _timeFormat = new DateFormat('H:m');

  User _user;
  bool _needInit = true;
  double _km;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(_party.date);
    if (_needInit) {
      var provider = Provider.of<UsersProvider>(context, listen: false);
      setState(() {
        _user = provider.activeUser;
      });
    }
    _needInit = false;
    return Container(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          _party.isOnline
              ? Column(
                  children: <Widget>[
                    Icon(Icons.web_asset),
                    Container(
                        width: 50.0,
                        child: Text(_party.headquarter,
                            overflow: TextOverflow.ellipsis)),
                  ],
                )
              : _getDistanceWidget(context),
          _numberPlayersWidget(),
          Column(
            children: <Widget>[
              Icon(Icons.timer),
              Text('${_timeFormat.format(dateTime)}'),
            ],
          ),
          Column(
            children: <Widget>[
              Icon(Icons.calendar_today),
              Text('${_dayFormat.format(dateTime)}')
            ],
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
    _getKm();
    return Column(
      children: <Widget>[
        Icon(Icons.location_on),
        _km == null ? Text('$_city') : Text('${_km.toStringAsFixed(1)}km'),
      ],
    );
  }

  String _city = '';

  void _getPlace() async {
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        _party.getLatLong().latitude, _party.getLatLong().longitude);

    // this is all you need
    Placemark placeMark = placemark[0];

    setState(() {
      _city = placeMark.locality; // update _address
    });
  }

  void _getKm() {
    if (_user != null && _user.latitude != null) {
      _getDistance();
    } else {
      _getPlace();
      while (_user != null && _user.latitude != null) {
        if (_user != null && _user.latitude != null) {
          _getDistance();
        }
      }
    }
  }

  void _getDistance() {
    setState(() {
      _km = Distance().as(
          LengthUnit.Kilometer,
          LatLng(_user.latitude, _user.longitude),
          LatLng(_party.getLatLong().latitude, _party.getLatLong().longitude));
    });
  }
}
