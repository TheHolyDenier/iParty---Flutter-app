import 'package:flutter/material.dart';

class MyTextAvatarCircle extends StatelessWidget {
  final String _letter;

  MyTextAvatarCircle(this._letter);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          _letter,
        ),
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
