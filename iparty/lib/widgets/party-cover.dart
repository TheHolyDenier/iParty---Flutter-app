import 'package:flutter/material.dart';
import 'package:iparty/models/party.dart';

class PartyCoverWidget extends StatelessWidget {
  final Party _party;

  PartyCoverWidget(this._party);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width / 16 * 6,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/images/goblin_header.png',
          image: _party.imageUrl,
        ),
      ),
    );
  }
}
