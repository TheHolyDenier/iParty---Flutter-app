import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UploadingDialog extends StatefulWidget {
  final bool close;

  UploadingDialog(this.close);

  @override
  _UploadingDialogState createState() => _UploadingDialogState();
}

class _UploadingDialogState extends State<UploadingDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Su imagen se está procesando. Espere'),
      content: SpinKitWanderingCubes(
        size: 25.0,
        color: Theme.of(context).primaryColor,
      ),
      actions: <Widget>[
        if (this.widget.close)
          RaisedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          )
      ],
    );
  }
}
