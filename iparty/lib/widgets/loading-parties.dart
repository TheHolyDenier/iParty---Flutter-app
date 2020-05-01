import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import '../models/party.dart';
import '../models/user.dart';
import '../screens/party-summary.dart';
import './party-cover.dart';
import './party-details-summary.dart';

class PartiesWidget extends StatefulWidget {
  User user;

  PartiesWidget(this.user);

  @override
  _PartiesWidgetState createState() => _PartiesWidgetState(user);
}

class _PartiesWidgetState extends State<PartiesWidget> {
  final _databaseReference = Firestore.instance;

  User user;

  _PartiesWidgetState(this.user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _databaseReference
            .collection('parties')
            .where('date', isGreaterThan: DateTime.now())
            .orderBy('date')
            .snapshots(),
        builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return ListView(
              children: _getProjectsWidget(snapshot),
            );
          }
        });
  }

  _getProjectsWidget(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.map((doc) {
      Party party = Party.fromFirestore(doc);

      return _isPartyOk(party) ? _getPartyDetails(party) : Container();
    }).toList();
  }

  Widget _getPartyDetails(Party party) {
    String isCampaign = party.isCampaign ? 'Una campaña' : 'Una sesión';
    String isRpg = party.isRpg ? 'rol' : 'juego de mesa';
    String whatGame = party.game != '' ? ' de ${party.game}' : '';
    String isOnline = party.isOnline ? 'online' : '';
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(PartySummaryScreen.routeName, arguments: party);
          },
          child: Card(
            elevation: 5.0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    PartyCoverWidget(party),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        color: Colors.black54,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              '$isCampaign de $isRpg $whatGame $isOnline',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            _titlePartyWidget(party),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(children: <Widget>[
                    PartyDetailsWidget(party),
                    SizedBox(height: 10.0),
                    if (party.summary != '')
                      Container(
                        width: double.infinity,
                        child: Text(
                          party.summary,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePartyWidget(Party party) {
    return Container(
      height: 40.0,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        child: Text(
          party.title,
          textAlign: TextAlign.right,
          style: Theme.of(context)
              .textTheme
              .headline1
              .copyWith(color: Colors.white, height: 1),
        ),
      ),
    );
  }

  bool _isPartyOk(Party party) {
    var owner = party.playersUID[0] != user?.uid;
    var rpg = party.isRpg ? user?.rpg : true;
    var table = !party.isRpg ? user?.table : true;
    var safe = user.safe ? party.isSafe : true;
    var online = party.isOnline ? user.online : true;
    var farAway = true;
    if (!party.isOnline && user?.latitude != null && user.km >= 1.0) {
      var distance = Distance().as(
          LengthUnit.Kilometer,
          LatLng(user?.latitude, user.longitude),
          LatLng(party.getLatLong().latitude, party.getLatLong().longitude));
      farAway = distance <= user.km;
    }
    return owner && rpg && table && safe && online && farAway;
  }
}
