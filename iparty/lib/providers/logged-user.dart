import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class LoggedUser extends ChangeNotifier {
  User _user;

  get user => [_user];
}

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  Future logout() async {
    var result = FirebaseAuth.instance.signOut();
    notifyListeners();
    return result;
  }

  Future<FirebaseUser> loginUser({String email, String password}) async {
    try {
      AuthResult result = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result.user;
    } catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }
}

