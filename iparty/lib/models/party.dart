import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StatusJoin{
  NaN,
  Ok,
  Leave,
  Error
}

class Party {
  final String uid;
  String title;
  String imageUrl;
  String summary;
  String game;
  Map<String, dynamic> players;
  List<dynamic> playersUID;
  bool isRpg;
  bool isCampaign;
  bool isOnline;
  bool isSafe;
  String headquarter;
  DateTime date;

  Party({
    @required this.uid,
    @required this.title,
    this.game,
    this.imageUrl,
    this.summary,
    @required this.players,
    this.playersUID,
    @required this.isRpg,
    @required this.isCampaign,
    @required this.isOnline,
    @required this.isSafe,
    @required this.headquarter,
    @required this.date,
  });

  LatLng getLatLong() {
    if (!isOnline) {
      var splitted = headquarter.split('_');
      return LatLng(double.parse(splitted[0]), double.parse(splitted[1]));
    } else {
      return null;
    }
  }

  factory Party.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return Party(
      uid: doc.documentID,
      title: data['title'],
      game: data['game'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      summary: data['summary'] ?? '',
      players: data['players'],
      playersUID: data['playersUID'] ?? List(),
      isRpg: data['isRpg'] != null ? data['isRpg'] == '1' : true,
      isCampaign: data['isCampaign'] != null ? data['isCampaign'] == '1' : true,
      isOnline: data['isOnline'] != null ? data['isOnline'] == '1' : true,
      isSafe: data['safe'] != null ? data['safe'] == '1' : true,
      headquarter: data['headquarter'],
//      date: DateTime.fromMillisecondsSinceEpoch(data['date']),
      date: data['date'].toDate(),
    );
  }
}
