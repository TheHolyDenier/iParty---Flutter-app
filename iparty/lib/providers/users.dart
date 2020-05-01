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

  updateActiveUser(
      {String bio = '',
      String imageUrl = '',
      LatLng latLng,
      double km = 0.0,
      bool rpg = true,
      bool table = true,
      bool safe = true,
      bool online = true}) {
    _activeUser.bio = (bio != null && bio.isNotEmpty) ? bio : '';
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

}
