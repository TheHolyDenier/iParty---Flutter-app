import 'package:flutter/material.dart';
import 'package:iparty/models/user.dart';

import 'avatar-circles.dart';

class ProfileWidget extends StatelessWidget {
  final User user;

  ProfileWidget(this.user);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Hero(
            tag: user.uid,
            child: Container(
              width: 80,
              height: 80,
              child: user.imageUrl == ''
                  ? MyTextAvatarCircle(user.displayName[0])
                  : MyImageAvatarCircle(user.imageUrl, true),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(user.displayName, overflow: TextOverflow.ellipsis),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(user.bio),
      ),
      actions: <Widget>[
        RaisedButton(
            child: Text('Vale'), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
