import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDialog extends StatefulWidget {
  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  bool _searchLoc = false;
  bool _searchingByAddress = true;
  LatLng _center = const LatLng(40.974737, -5.672455);
  GoogleMapController _mapController;
  Map<MarkerId, Marker> _marker = <MarkerId, Marker>{};
  final _searchAddressController = TextEditingController();
  final double _zoom = 18.0;
  final _markerId = MarkerId('headquarter');

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _searchAddressController.dispose();
    super.dispose();
  }

//  Search for current location
  _getCurrentLocation() async {
    if (!_searchLoc) {
      await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        _center = LatLng(position.latitude, position.longitude);
        _moveMarker(_center);
      });

      _searchLoc = true;
    }
  }

//  Moves camera to current location and sets marker
  void _moveMarker(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: _zoom),
    ));
    final Marker marker = Marker(
      markerId: _markerId,
      position: position,
      draggable: true,
      onDragEnd: ((value) {
        _center = LatLng(value.latitude, value.longitude);
      }),
    );

    setState(() {
      _marker[_markerId] = marker;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentLocation();
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: Icon(Icons.done),
              onPressed: _marker.length == 0
                  ? null
                  : () => Navigator.pop(context,
                      '${_marker[_markerId].position.latitude}_${_marker[_markerId].position.longitude}'),
            )
          ],
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text('Base de operaciones'),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: _zoom,
                ),
                markers: Set<Marker>.of(_marker.values),
                onCameraMove: _onCameraMove,
              ),
            ),
            _widgetSearchBar(),
            _widgetSearchButton(),
          ],
        ));
  }

  FloatingActionButton _widgetSearchButton() {
    return FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () {
              if (!_searchingByAddress) {
                setState(() => _searchingByAddress = true);
              } else {
                _searchByAddress();
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            disabledElevation: 0,
          );
  }

  Positioned _widgetSearchBar() {
    return Positioned(
            top: 0,
            right: _searchingByAddress ? 0 : (double.infinity),
            left: 0,
            child: Container(
              height: 60,
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: _searchAddressController,
                onSubmitted: (_) => _searchByAddress(),
//                    onChanged: onTextChange,
                decoration: InputDecoration(
                    hintText: 'Calle, número, código postal...',
                    hintStyle: TextStyle(color: Colors.black),
                    fillColor: Colors.black.withOpacity(0.1),
                    filled: true,
                    suffixIcon: _searchingByAddress
                        ? IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() => _searchingByAddress = false);
                              _searchAddressController.text = '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.only(left: 35)),
              ),
            ),
          );
  }

//  Searches lat/long by address
  void _searchByAddress() async {
    String address = _searchAddressController.text;
    await Geolocator()
        .placemarkFromAddress(address)
        .then((List<Placemark> placemarks) {
      _moveMarker(LatLng(
          placemarks[0].position.latitude, placemarks[0].position.longitude));
    });
  }
}
