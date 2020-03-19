import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return User(
      uid: doc.documentID,
      displayName: data['displayName'],
      email: data['email'],
      imageUrl: data['imageUrl'] ?? '',
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      filters: data['filters'] ?? '',
    );
  }

  toJson() {
    return {
      'uid': this.uid,
      'email': this.email,
      'displayName': this.displayName,
      'imageUrl': this.imageUrl,
      'bio': this.bio,
      'location': this.location,
      'filters': this.filters,
    };
  }
}
