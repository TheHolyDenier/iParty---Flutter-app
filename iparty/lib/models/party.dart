import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iparty/models/user.dart';

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
  String date;

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
      isRpg: data['isRpg'] != null ? data['rpg'] == '1' : true,
      isCampaign: data['isCampaign'] != null ? data['isCampaign'] == '1' : true,
      isOnline: data['isOnline'] != null ? data['isOnline'] == '1' : true,
      isSafe: data['safe'] != null ? data['safe'] == '1' : true,
      headquarter: data['headquarter'],
      date: data['date'],
    );
  }
}
