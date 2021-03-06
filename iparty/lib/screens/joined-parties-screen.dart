import 'package:flutter/material.dart';

import '../models/party.dart';
import '../models/user.dart';
import '../widgets/drawer.dart';
import '../widgets/loading-parties.dart';

class PartiesScreen extends StatefulWidget {
  static final routeName = '/parties-screen';

  @override
  _PartiesScreenState createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  var _master = true;
  var _player = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tus mesas'),
        actions: <Widget>[
          ChoiceChip(
            label: Icon(Icons.person),
            selected: _master,
            onSelected: (value) {
              setState(() {
                _master = value;
              });
            },
            selectedColor: Theme.of(context).accentColor,
          ),
          SizedBox(
            width: 10.0,
          ),
          ChoiceChip(
            label: Icon(Icons.people),
            selected: _player,
            onSelected: (value) {
              setState(() {
                _player = value;
              });
            },
            selectedColor: Theme.of(context).accentColor,
          ),
        ],
      ),
      body: PartiesWidget(_isPartyOk, joined: true),
      drawer: MyDrawer(),
    );
  }

  bool _isPartyOk(Party party, User user) {
//      If it's being played and on date
    if (party.date.isBefore(DateTime.now()) &&
        !(party.isCampaign && !party.isFinished)) {
      return false;
    }
    //    If its your party
    var owner = party.playersUID[0] == user.uid;
//    If you're a party member, but not owner
    var player = party.playersUID.contains(user.uid) && !owner;
//    If it's active
    return (_master ? owner : false) || (_player ? player : false);
  }
}
