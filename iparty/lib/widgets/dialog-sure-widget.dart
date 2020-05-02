import 'package:flutter/material.dart';

class DialogSureWidget extends StatelessWidget {
  final String title, text;

  DialogSureWidget(this.title, this.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[Text(text)],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Sí, estoy seguro'),
          onPressed: () => Navigator.of(context).pop(1),
        ),
        RaisedButton(
          child: Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(0),
        ),
      ],
    );
  }
}
