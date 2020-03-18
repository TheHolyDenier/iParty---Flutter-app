import 'package:flutter/material.dart';

class Party {
  final String uid;
  String title;
  String imageUrl;
  String summary;
  String game; 
  Map<String, int> players;
  bool isRpg;
  bool isCampaign;
  bool isOnline;
  String headquarter;
  String date;
  String filters;

  Party({
    @required this.uid,
    @required this.title,
    this.game,
    this.imageUrl,
    @required this.summary,
    @required this.players,
    @required this.isRpg,
    @required this.isCampaign,
    @required this.isOnline,
    @required this.headquarter,
    @required this.date,
    this.filters,
  });
}
