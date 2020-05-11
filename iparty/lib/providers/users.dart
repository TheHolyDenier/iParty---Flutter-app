import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/user.dart';

class UsersProvider with ChangeNotifier {
  User _activeUser;
  bool userGot = true;

  User get activeUser => _activeUser;

  setActiveUser(User user) {
    _activeUser = user;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }

  updateActiveUser(
      {String bio = '',
      String imageUrl = '',
      LatLng latLng,
      double km = 0.0,
      bool rpg = true,
      bool table = true,
      bool safe = true,
      bool online = true}) {
    _activeUser.bio = (bio != null && bio.isNotEmpty) ? bio : _activeUser.bio;
    _activeUser.imageUrl = imageUrl ?? _activeUser.imageUrl;
    if (latLng != null) {
      _activeUser.latitude = latLng.latitude;
      _activeUser.longitude = latLng.longitude;
    }
    _activeUser.km = km ?? _activeUser.km;
    _activeUser.rpg = rpg ?? _activeUser.rpg;
    _activeUser.table = table ?? _activeUser.table;
    _activeUser.safe = safe ?? _activeUser.safe;
    _activeUser.online = online ?? _activeUser.online;
    notifyListeners();
  }
}
