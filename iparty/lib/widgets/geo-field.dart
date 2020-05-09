import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map-dialog.dart';

class AddressWidget extends StatefulWidget {
  final TextEditingController controllerGeo;
  final LatLng latLng;
  final Function callback;

  AddressWidget({this.controllerGeo, this.latLng, this.callback});

  @override
  _AddressWidgetState createState() => _AddressWidgetState(
      controllerGeo: controllerGeo, latLng: latLng, callback: callback);
}

class _AddressWidgetState extends State<AddressWidget> {
  final TextEditingController controllerGeo;
  Function callback;
  LatLng latLng;

  _AddressWidgetState({this.controllerGeo, this.latLng, this.callback});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (latLng != null) {
      _searchAddress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextFormField(
          enabled: false,
          controller: controllerGeo,
          decoration: const InputDecoration(
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
        if (latLng == null) {
          return MapDialog(
            notSearching: callback != null,
          );
        }
        return MapDialog(notSearching: callback != null, latLng: latLng);
      },
    ).then((result) async {
      // Translates address
      if (result != null) {
        setState(() {
          latLng = LatLng(double.parse(result.split('_')[0]),
              double.parse(result.split('_')[1]));
          callback(latLng);
        });
        _searchAddress();
      }
    });
  }

  // Searches address of lat/long
  _searchAddress() async {
    await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude)
        .then((address) {
      setState(() {
        controllerGeo.text =
            '${address[0].thoroughfare} ${address[0].name}, ${address[0].locality}';
      });
    });
  }
}
