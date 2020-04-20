import 'package:flutter/material.dart';
import 'package:iparty/models/enums.dart';

class StateWidget extends StatelessWidget {
  StatusUpload _statusUpload;

  StateWidget(this._statusUpload);

//  @override
//  _StateWidgetState createState() => _StateWidgetState(_statusUpload);
//}
//
//class _StateWidgetState extends State<StateWidget> {
//  StatusUpload _statusUpload;
//
//  _StateWidgetState(this._statusUpload);

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
                CircularProgressIndicator(),
                SizedBox(width: 5.0),
                Text('Subiendo...'),
              ],
            ),
          )
      ],
    );
  }
}
