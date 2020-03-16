import 'dart:async';

import 'package:flutter/material.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;
  String bio;
  String location;
  String filters;

  User({
    @required this.uid,
    @required this.email,
    this.username,
    this.imageUrl,
    this.bio,
    this.location,
    this.filters,
  });

  factory User.fromMap(Map data) {
    return User(
      uid: data['uid'],
      username: data['username'],
      email: data['email'],
      imageUrl: data['imageUrl'],
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      filters: data['filters'] ?? '',
    );
  }
}
