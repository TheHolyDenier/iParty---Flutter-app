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
  bool searchLoc = false;
  bool _searchingByAddress = false;
  LatLng _center = const LatLng(40.974737, -5.672455);
  GoogleMapController _mapController;
  Map<MarkerId, Marker> _marker = <MarkerId, Marker>{};

  _getCurrentLocation() async {
    if (!searchLoc) {
      await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _center, zoom: 20.0),
            ),
          );
          final markerId = MarkerId('headquarter');
          final Marker marker = Marker(
            markerId: markerId,
            position: _center,
            draggable: true,
            onDragEnd: ((value) {
              print(value.latitude);
              print(value.longitude);
              _center = LatLng(value.latitude, value.longitude);
            }),
          );

          setState(() {
            _marker[markerId] = marker;
          });
        });
      });

      searchLoc = true;
    }
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
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
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 20.0,
              ),
              markers: Set<Marker>.of(_marker.values),
              onCameraMove: _onCameraMove,
            ),
            _searchingByAddress
                ? Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(8),
                      child: TextField(
//                    onChanged: onTextChange,
                        decoration: InputDecoration(
                            fillColor: Colors.black.withOpacity(0.1),
                            filled: true,
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                setState(() => _searchingByAddress = false);
                              },
                            ),
//                      hintText: 'Search something ...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.zero),
                      ),
                    ),
                  )
                : FloatingActionButton(
                    child: Icon(Icons.search),
                    onPressed: () {
                      setState(() => _searchingByAddress = true);
                    },
                  ),
          ],
        ));
  }
}

//    print('entra');
//    var addresses = await Geocoder.local.findAddressesFromQuery(_searchAddress);
//    var first = addresses.first;
//    print('Localización ${first.featureName} : ${first.coordinates}');
