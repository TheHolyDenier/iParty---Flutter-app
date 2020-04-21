import 'package:flutter/material.dart';
import 'package:iparty/models/party.dart';

class PartyCoverWidget extends StatelessWidget {
  final Party _party;
  final isSummary;

  PartyCoverWidget(this._party, {this.isSummary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isSummary ? 200 : MediaQuery.of(context).size.width / 16 * 6,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Hero(
          tag: _party.uid,
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/goblin_header.png',
            image: _party.imageUrl,
          ),
        ),
      ),
    );
  }
}
