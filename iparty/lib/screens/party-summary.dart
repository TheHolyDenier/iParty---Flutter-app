import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iparty/widgets/geo-field.dart';
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
  Color _color = Colors.white;
  bool _gotColor = false;
  StatusJoin _statusJoin = StatusJoin.NaN;

  @override
  Widget build(BuildContext context) {
    _party = ModalRoute.of(context).settings.arguments;
    if (!_gotColor) {
      _getColor();
      _gotColor = true;
    }
    _provider = Provider.of<UsersProvider>(context);
    _getUsers();

    User _owner = _provider.findByUid(_party.playersUID[0]);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              // Header
              children: <Widget>[
                PartyCoverWidget(
                  _party,
                  isSummary: true,
                ),
                _backwardWidget(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: _owner != null
                      ? _ownerWidget(_owner, context)
                      : Container(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  _titleWidget(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      // DETAILS
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 20.0),
                        child: PartyDetailsWidget(_party),
                      ),
                    ),
                  ),
                  if (_statusJoin == StatusJoin.Ok)
                    _joinedWidget(),
                  // JOINED
                  if (_statusJoin == StatusJoin.Error)
                    _errorWidget(context),
                  // STATUS ERROR
                  if (_party.players['max'] > _party.playersUID.length - 1 &&
                      !_party.playersUID.contains(_provider.activeUser.uid))
                    RaisedButton(
                      // JOIN IF NOT OWNER - PARTY MEMBER
                      child: Text('¡Apúntate!'),
                      onPressed: _joinParty,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        width: double.infinity,
                        child: _partyDetails(), // PARTY DETAILS
                      ),
                    ),
                  ),
                  if (_party.playersUID.length > 1)
                    _playersInfo(), // PARTY MEMBERS - NOT OWNER
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partyDetails() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 10.0),
          width: double.infinity,
          child: Text(
            'Datos de la partida:',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        if (_party.summary != '' || _party.game != '')
          Container(
            width: double.infinity,
            child: Wrap(
              children: <Widget>[
                Text(
                  _party.game,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10.0),
                Text(
                  _party.summary,
                  softWrap: true,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        if (_party.playersUID.contains(_provider.activeUser.uid))
          Container(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  if (!_party.isOnline)
                    AddressWidget(
                      latLng: _party.getLatLong(),
                    ),
                  _party.isOnline && Uri.parse(_party.headquarter).isAbsolute
                      ? Container(
                          child: Text('Es una url!'),
                        )
                      : Container(
                          width: double.infinity,
                          child: Wrap(
                            children: <Widget>[
                              Text('La partida se hará a través de '),
                              Text(
                                _party.headquarter,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                ],
              ))
      ],
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Center(
      child: Text(
        'Ha habido un error. Pruebe de nuevo más tarde',
        style: TextStyle(color: Theme.of(context).errorColor),
      ),
    );
  }

  Widget _joinedWidget() {
    return Center(
      child: Text(
        '¡Bienvenido a la partida!',
        style: TextStyle(color: Colors.green),
      ),
    );
  }

  Widget _titleWidget(BuildContext context) {
    return Text(
      _party.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.headline4,
      textAlign: TextAlign.center,
    );
  }

  Widget _backwardWidget() {
    return Positioned(
      top: 0.0,
      left: 0.0,
      child: SafeArea(
        child: IconButton(
          icon: Icon(Icons.arrow_back,
              color: _gotColor == false || _color.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _ownerWidget(User _owner, BuildContext context) {
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

  Widget _playersInfo() {
    List<User> players = List();
    _party.playersUID.asMap().forEach((index, value) {
      if (index != 0) {
        players.add(_provider.findByUid(value));
      }
    });
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              width: double.infinity,
              child: Text(
                'Plazas ocupadas (${(_party.playersUID.length - 1).toStringAsFixed(0)}/${(_party.players['max']).toStringAsFixed(0)}):',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            if (_party.players['min'] > (_party.playersUID.length - 1))
              Container(
                child: Text(
                  'Recuerda que el creador de esta partida ha establecido un mínimo de jugadores de ${_party.players['min'].toStringAsFixed(0)} (hace falta ${(_party.players['min'] - (_party.playersUID.length - 1)).toStringAsFixed(0)} más) y puede que no se realice .',
                  style: TextStyle(fontSize: 10.0),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  for (var player in players)
                    Container(
                      width: 50.0,
                      height: 50.0,
                      child: player.imageUrl != ''
                          ? MyImageAvatarCircle(player.imageUrl, true)
                          : MyTextAvatarCircle(player.displayName[0]),
                    ),
                ],
              ), // PLAYERS
            )
          ],
        ),
      ),
    );
  }

  void _getUsers() {
    for (String uid in _party.playersUID) {
      _provider.addOneUser(uid, false);
    }
  }

  Future<void> _getColor() async {
    String url;
    if (_party.imageUrl == '') {
      url = 'assets/images/goblin_header.png';
    } else {
      url = _party.imageUrl;
    }
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      _party.imageUrl == '' ? AssetImage(url) : NetworkImage(url),
      size: Size(500, 250),
      region: Offset.zero & Size(40, 40),
    );
    setState(() {
      _color = palette.colors?.first;
    });
    if (_color == null) _getColor();
  }

  void _joinParty() {
    _party.playersUID.add('${_provider.activeUser.uid}');
    Firestore.instance.collection('parties').document(_party.uid).updateData({
      'playersUID': _party.playersUID,
    }).then((_) {
//      Sets ok message
      setState(() {
        _statusJoin = StatusJoin.Ok;
        _getUsers();
      });
    }).catchError((error) {
      // Not ok
      setState(() {
        _statusJoin = StatusJoin.Error;
      });
      print(error.toString());
    });
  }
}
