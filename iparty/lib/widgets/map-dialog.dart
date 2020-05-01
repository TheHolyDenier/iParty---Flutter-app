import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDialog extends StatefulWidget {
  final bool notSearching;
  final LatLng latLng;

  MapDialog({this.notSearching = true, this.latLng});

  @override
  _MapDialogState createState() =>
      _MapDialogState(notSearching: notSearching, center: latLng);
}

class _MapDialogState extends State<MapDialog> {
  bool _searchLoc = false;
  bool _searchingByAddress = true;
  LatLng center;
  GoogleMapController _mapController;
  Map<MarkerId, Marker> _marker = <MarkerId, Marker>{};
  final _searchAddressController = TextEditingController();
  final double _zoom = 18.0;
  final _markerId = MarkerId('headquarter');
  final bool notSearching;

  _MapDialogState(
      {this.notSearching, this.center = const LatLng(40.974737, -5.672455)});

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
        center = LatLng(position.latitude, position.longitude);
        _moveMarker(center);
      });
      _searchLoc = true;
    }
  }

//  Moves camera to current location and sets marker
  void _moveMarker(LatLng position) {
    if (position == null) position = center;
    print('${position}');
    var cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: _zoom));
    _mapController.moveCamera(cameraUpdate);
    _setMarker(position);
  }

  void _setMarker(LatLng position) {
    final Marker marker = Marker(
      markerId: _markerId,
      position: position,
      draggable: true,
      onDragEnd: ((value) {
        center = LatLng(value.latitude, value.longitude);
      }),
    );

    setState(() {
      _marker[_markerId] = marker;
    });
  }

  void _onCameraMove(CameraPosition position) {
    center = position.target;
  }

  @override
  Widget build(BuildContext context) {
    if (notSearching)
      _getCurrentLocation();
    else
      _setMarker(center);
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            if (notSearching)
              FlatButton(
                child: Icon(Icons.done),
                onPressed: _marker.length == 0
                    ? null
                    : () => Navigator.pop(
                        context, '${center.latitude}_${center.longitude}'),
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
                  target: center?? LatLng(40.974737, -5.672455),
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
      if (placemarks != null) {
        _moveMarker(LatLng(
            placemarks[0].position.latitude, placemarks[0].position.longitude));
      }
    });
  }
}
