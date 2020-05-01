import 'package:flutter/material.dart';

class PartyActionsWidget extends StatefulWidget {
  @override
  _PartyActionsWidgetState createState() => _PartyActionsWidgetState();
}

class _PartyActionsWidgetState extends State<PartyActionsWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (_isOpen)
          Column(
            children: <Widget>[
              FloatingActionButton(
                heroTag: 'finish',
                onPressed: () {},
                child: Icon(Icons.delete),
              ),
              SizedBox(height: 10.0),
              FloatingActionButton(
                heroTag: 'delete-user',
                onPressed: () {},
                child: Icon(Icons.not_interested),
              ),
              SizedBox(height: 10.0),
              FloatingActionButton(
                heroTag: 'add-user',
                onPressed: () {},
                child: Icon(Icons.person_add),
              ),
              SizedBox(height: 10.0),
              FloatingActionButton(
                heroTag: 'cover',
                onPressed: () {},
                child: Icon(Icons.add_photo_alternate),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        FloatingActionButton(
          backgroundColor: _isOpen ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
          heroTag: 'settings',
          onPressed: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          child: Icon(_isOpen ? Icons.close : Icons.settings),
        ),
      ],
    );
  }
}
