import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/user.dart';

class UsersProvider with ChangeNotifier {
  final Firestore _db = Firestore.instance;
  Map<String, User> _users = {};
  User _activeUser;

  User get activeUser => _activeUser;

  updateActiveUser(
      {String bio = '',
      String imageUrl = '',
      LatLng latLng,
      double km = 0.0,
      bool rpg = true,
      bool table = true,
      bool safe = true,
      bool online = true}) {
    _activeUser.bio = bio ?? '';
    _activeUser.imageUrl = imageUrl ?? '';
    if (latLng != null) {
      _activeUser.latitude = latLng.latitude;
      _activeUser.longitude = latLng.longitude;
    }
    _activeUser.km = km ?? 0.0;
    _activeUser.rpg = rpg ?? true;
    _activeUser.table = table ?? true;
    _activeUser.safe = safe ?? true;
    _activeUser.online = online ?? true;
    notifyListeners();
  }

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
