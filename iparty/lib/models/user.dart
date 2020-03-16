import 'package:flutter/material.dart';

class User {
  final String uid;
  final String displayName;
  final String email;
  String imageUrl;
  String bio;
  String location;
  String filters;

  User({
    @required this.uid,
    @required this.email,
    @required this.displayName,
    this.imageUrl,
    this.bio,
    this.location,
    this.filters,
  });

  factory User.fromMap(Map data) {
    return User(
      uid: data['uid'],
      displayName: data['displayName'],
      email: data['email'],
      imageUrl: data['imageUrl'],
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      filters: data['filters'] ?? '',
    );
  }
}
