import 'package:flutter/material.dart';

class MyTextAvatarCircle extends StatelessWidget {
  final String _letter;

  MyTextAvatarCircle(this._letter);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Text(
        _letter,
        style: TextStyle(fontSize: 40.0),
      ),
    );
  }
}

class MyImageAvatarCircle extends StatelessWidget {
  final String imageUrl;
  final bool isNetwork;

  MyImageAvatarCircle(this.imageUrl, this.isNetwork);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage:
          isNetwork ? NetworkImage(imageUrl) : AssetImage(imageUrl),
    );
  }
}
