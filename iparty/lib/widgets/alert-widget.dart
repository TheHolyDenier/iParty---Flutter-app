import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iparty/models/party.dart';

class AlertWidget extends StatefulWidget {
  final Party party;
  final String uid;

  AlertWidget(this.party, this.uid);

  @override
  _AlertWidgetState createState() => _AlertWidgetState(party, uid);
}

class _AlertWidgetState extends State<AlertWidget> {
  Party party;
  final String uid;

  var _databaseReference = Firestore.instance;
  _AlertWidgetState(this.party, this.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _databaseReference
            .collection('alerts')
            .where('player', isEqualTo: uid)
            .where('parties', arrayContains: party.uid)
            .snapshots(),
        builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return snapshot.data.documents.length > 0
                ? Positioned(
                    right: 0,
                    child: Badge(
                      badgeContent: Icon(Icons.add_alert, color: Colors.white),
                      child: Icon(Icons.settings),
                    ),
                  )
                : Container();
          }
        });
  }
}
