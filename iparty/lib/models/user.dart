import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String uid, displayName, email;
  String imageUrl, bio;
  double latitude, longitude, km;
  bool rpg, table, safe, online;

  User({
    @required this.uid,
    @required this.email,
    @required this.displayName,
    this.imageUrl = '',
    this.bio = '',
    this.latitude = 40.974737,
    this.longitude = -5.672455,
    this.km = 0.0,
    this.rpg = true,
    this.table = true,
    this.safe = true,
    this.online = true,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return User(
      uid: doc.documentID,
      displayName: data['displayName'],
      email: data['email'],
      imageUrl: data['imageUrl'] ?? '',
      bio: data['bio'] ?? '',
      latitude: data['latitude'] != null
          ? double.tryParse(data['latitude'])
          : 40.974737,
      longitude: data['longitude'] != null
          ? double.tryParse(data['longitude'])
          : -5.672455,
      km: data['km'] != null ? double.tryParse(data['km']) : 0.0,
      rpg: data['rpg'] != null ? data['rpg'] == '1' : true,
      table: data['table'] != null ? data['table'] == '1' : true,
      safe: data['safe'] != null ? data['safe'] == '1' : true,
      online: data['online'] != null ? data['online'] == '1' : true,
    );
  }
}
