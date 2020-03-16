import 'package:flutter/cupertino.dart';
import 'package:iparty/models/user.dart';

class LoggedUser extends ChangeNotifier{
  User _user;

  get user => [_user];
}