import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDialog extends StatefulWidget {
  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _center = const LatLng(40.974737, -5.672455);
  final Set<Marker> _markers = {};

  _getCurrentLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });

  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentLocation();
    return Scaffold(
        appBar: AppBar(
          title: Text("Google Maps"),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 50.0,
              ),
              markers: {
                Marker(
                    onTap: () {
                      print('Tapped');
                    },
                    draggable: true,
                    markerId: MarkerId('Marker'),
                    position: _center,
                    onDragEnd: ((value) {
                      print(value.latitude);
                      print(value.longitude);
                    }))
              },
              onCameraMove: _onCameraMove,
            ),
          ],
        ));
  }
}

//    print('entra');
//    var addresses = await Geocoder.local.findAddressesFromQuery(_searchAddress);
//    var first = addresses.first;
//    print('Localización ${first.featureName} : ${first.coordinates}');
