import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map-dialog.dart';

class AddressWidget extends StatefulWidget {
  final TextEditingController _controllerGeo;
  LatLng _latLng;

  AddressWidget(this._controllerGeo, this._latLng);

  @override
  _AddressWidgetState createState() => _AddressWidgetState(_controllerGeo, _latLng);
}

class _AddressWidgetState extends State<AddressWidget> {
  final TextEditingController _controllerGeo;
  LatLng _latLng;
  _AddressWidgetState(this._controllerGeo, this._latLng);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextFormField(
          enabled: false,
          controller: _controllerGeo,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.only(right: 45.0),
              icon: Icon(Icons.map),
              labelText: 'Base de operaciones'),
        ),
        Positioned(
          child: IconButton(
            icon: Icon(Icons.location_searching,
                color: Theme.of(context).accentColor),
            onPressed: _setLocation,
          ),
          right: 0,
          top: 0,
          bottom: 0,
        ),
      ],
    );
  }

  //  Shows dialog and, when it's closed, translates de params to lat/long
  Future<void> _setLocation() async {
    await showDialog<String>(
      // Shows dialog
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return MapDialog();
      },
    ).then((result) async {
      // Translates address
      if (result != null) {
        _latLng = LatLng(double.parse(result.split('_')[0]),
            double.parse(result.split('_')[1]));
        _searchAddress();
      }
    });
  }

  // Searches address of lat/long
  _searchAddress() async {
    await Geolocator()
        .placemarkFromCoordinates(_latLng.latitude, _latLng.longitude)
        .then((address) {
      _controllerGeo.text =
      '${address[0].thoroughfare} ${address[0].name}, ${address[0].locality}';
    });
  }
}
