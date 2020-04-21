import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../models/party.dart';
import '../models/user.dart';
import '../providers/users.dart';
import '../widgets/party-details-summary.dart';
import '../widgets/avatar-circles.dart';
import '../widgets/party-cover.dart';

class PartySummaryScreen extends StatefulWidget {
  static final routeName = '/party-summary';

  @override
  _PartySummaryScreenState createState() => _PartySummaryScreenState();
}

class _PartySummaryScreenState extends State<PartySummaryScreen> {
  final _databaseReference = Firestore.instance;

  UsersProvider _provider;
  Party _party;
  Color _color;

  @override
  Widget build(BuildContext context) {
    _party = ModalRoute.of(context).settings.arguments;
    if (_party.imageUrl != '' && _color == null) _getColor();
    _provider = Provider.of<UsersProvider>(context);
    _getUsers();
    User _owner = _provider.findByUid(_party.playersUID[0]);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                PartyCoverWidget(_party), // Image
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: _ownerWidget(_owner, context),
                ),
                Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: _color == null || _color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Text(
                    _party.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 20.0),
                        child: PartyDetailsWidget(_party),
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('¡Apúntate!'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _party.summary,
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  if (_party.playersUID.length > 1) _playersInfo(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _ownerWidget(User _owner, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      width: double.infinity,
      color: Colors.black45,
      child: ListTile(
        leading: _owner.imageUrl == ''
            ? MyTextAvatarCircle(_owner?.displayName[0])
            : MyImageAvatarCircle(_owner.imageUrl, true),
        title: Text(
          _owner?.displayName,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.white),
        ),
        trailing: Icon(
          Icons.navigate_next,
          color: Colors.white,
        ),
      ),
    );
  }

  Card _playersInfo(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Text(
              'Plazas ocupadas',
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(), // PLAYERS
            )
          ],
        ),
      ),
    );
  }

  _getUsers() {
    for (String uid in _party.playersUID) {
      _provider.addOneUser(uid, false);
    }
  }

  Future<void> _getColor() async {
    final url = _party.imageUrl;
    print('${_party.title}');
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      NetworkImage(url),
      size: Size(50, 50),
      region: Offset.zero & Size(40, 40),
    );
    print('paleta: ${palette.colors}');
    setState(() {
      _color = palette.colors.first;
    });
  }
}
