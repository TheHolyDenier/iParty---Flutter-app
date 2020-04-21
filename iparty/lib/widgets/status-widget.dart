import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iparty/models/enums.dart';

class StateWidget extends StatelessWidget {
  final StatusUpload _statusUpload;

  StateWidget(this._statusUpload);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (_statusUpload == StatusUpload.Error ||
            _statusUpload == StatusUpload.Ok)
          Container(
            child: Text(
              _statusUpload == StatusUpload.Ok
                  ? 'Cambios guardados.'
                  : 'Ha habido un error',
              style: TextStyle(
                  color: _statusUpload == StatusUpload.Ok
                      ? Colors.green
                      : Theme.of(context).errorColor),
            ),
          ),
        if (_statusUpload == StatusUpload.Uploading)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitWanderingCubes(
                  size: 25.0,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 5.0),
                Text('Subiendo...'),
              ],
            ),
          )
      ],
    );
  }
}
