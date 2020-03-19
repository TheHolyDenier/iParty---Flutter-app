import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class UsersProvider with ChangeNotifier {
  final Firestore _db = Firestore.instance;
  Map<String, User> _users = {};
  User _activeUser;

  User get activeUser => _activeUser; 

  Map<String, User> get users => {..._users};

  User findByUid(String uid) =>
      _users.values.firstWhere((user) => user.uid == uid);

  Future<void> addOneUser(String uid, bool active) async {
    if (!_users.keys.contains(uid)) {
      var doc = _db.collection('users').document(uid);

      doc.get().then((doc) {
        if (doc.exists) {
          _users.putIfAbsent(uid, () => User.fromFirestore(doc));
          if (active) _activeUser = User.fromFirestore(doc); 
          notifyListeners();
        } else {
          print('Not found');
        }
      }).catchError((error) {
        print(error.toString());
      });
    }
  }
}
