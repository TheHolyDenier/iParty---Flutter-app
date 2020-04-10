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
  final String _imageUrl;
  final bool _isNetwork;

  MyImageAvatarCircle(this._imageUrl, this._isNetwork);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage:
          _isNetwork
              ? NetworkImage(_imageUrl)
              : AssetImage(_imageUrl),
    );
  }
}
