import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: SpinKitCubeGrid(
            size: 150.0,
            color: Color.fromRGBO(255, 182, 161, 1),
          ),
          alignment: Alignment(0.0, 0.0),
        ),
      ),
    );
  }
}
