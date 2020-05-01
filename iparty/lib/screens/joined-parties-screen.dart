import 'package:flutter/material.dart';

import '../models/party.dart';
import '../models/user.dart';
import './table-screen.dart';
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
          ),
        ],
      ),
      body: PartiesWidget(_isPartyOk),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(NewTableScreen.routeName),
        child: Icon(Icons.add),
      ),
    );
  }

  bool _isPartyOk(Party party, User user) {
//    If you're in the party
    var joined = party.playersUID.contains(user.uid);
//    If its your party
    var owner = party.playersUID[0] == user.uid;
//    If you're a party member, but not owner
    var player = party.playersUID.contains(user.uid) && !owner;
    return joined && ((_master ? owner : false) || (_player ? player : false));
  }
}
