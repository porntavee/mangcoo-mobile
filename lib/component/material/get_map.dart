// ignore: must_be_immutable รูปฝั่งซ้าย หัวข้อกับคำอธิบายฝั่งขวา (vertical, ความยาวยืดสุดยืดสุด)
import 'dart:async';

import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetMapFull extends StatefulWidget {
  GetMapFull({
    Key key,
    this.model,
    this.navTo,
    this.latLng: const LatLng(0, 0),
    this.bounds,
  }) : super(key: key);

  final LatLng latLng;
  final LatLngBounds bounds;
  final dynamic model;
  final Function(dynamic) navTo;

  @override
  _GetMapFull createState() => _GetMapFull();
}

class _GetMapFull extends State<GetMapFull>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<GetMapFull> {
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.799388, 100.551395),
    zoom: 14.4746,
  );

  CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(13.799388, 100.551395),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    _kGooglePlex = CameraPosition(
      target: widget.latLng,
      zoom: 14.4746,
    );
    _kLake = CameraPosition(
        bearing: 192.8334901395799,
        target: widget.latLng,
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        mapType: MapType.normal,
        // initialCameraPosition: _kGooglePlex,
        initialCameraPosition: CameraPosition(target: widget.latLng, zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
          // controller.animateCamera(
          //   CameraUpdate.newCameraPosition(
          //     CameraPosition(target: widget.latLng, zoom: 14),
          //   ),
          // );
        },
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          new Factory<OneSequenceGestureRecognizer>(
            () => new EagerGestureRecognizer(),
          ),
        ].toSet(),
        markers: <Marker>[
          Marker(
            markerId: MarkerId(widget.model['code']),
            position: widget.latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              onTap: () {
                toastFail(context);
              },
              title: widget.model['title'].toString(),
            ),
          ),
        ].toSet(),
      ),
    );
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              mapType: MapType.normal,
              // initialCameraPosition: _kGooglePlex,
              initialCameraPosition:
                  CameraPosition(target: widget.latLng, zoom: 14),
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                // controller.animateCamera(
                //   CameraUpdate.newCameraPosition(
                //     CameraPosition(target: widget.latLng, zoom: 14),
                //   ),
                // );
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<OneSequenceGestureRecognizer>(
                  () => new EagerGestureRecognizer(),
                ),
              ].toSet(),
              markers: <Marker>[
                Marker(
                  markerId: MarkerId('1'),
                  position: widget.latLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(
                    onTap: () {
                      toastFail(context);
                    },
                    title: snapshot.data[0]['title'].toString(),
                  ),
                ),
              ].toSet(),
            ),
          );
          return googleMap(snapshot.data[0]);
        } else {
          return Container();
        }
      },
    );
  }

  FutureBuilder googleMap(modelData) {
    List<Marker> _markers = <Marker>[];

    return FutureBuilder<dynamic>(
      future: modelData, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            snapshot.data
                .map(
                  (item) => _markers.add(
                    Marker(
                      markerId: MarkerId(item['code']),
                      position: widget.latLng,
                      infoWindow: InfoWindow(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => PoiForm(
                          //       code: item['code'],
                          //       model: item,
                          //       url: poiApi,
                          //       urlComment: poiCommentApi,
                          //       urlGallery: poiGalleryApi,
                          //     ),
                          //   ),
                          // );
                        },
                        title: item['title'].toString(),
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  ),
                )
                .toList();
          }

          return GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.latLng,
              zoom: 15,
            ),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(
                () => new EagerGestureRecognizer(),
              ),
            ].toSet(),
            onMapCreated: (GoogleMapController controller) {
              controller.moveCamera(
                CameraUpdate.newLatLngBounds(
                  widget.bounds,
                  5.0,
                ),
              );
              controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: widget.latLng, zoom: 15)));
              _mapController.complete(controller);
            },
            // cameraTargetBounds: CameraTargetBounds(_createBounds()),
            markers: snapshot.data.length > 0
                ? _markers.toSet()
                : <Marker>[
                    Marker(
                      markerId: MarkerId('1'),
                      position: LatLng(0.00, 0.00),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  ].toSet(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              child: dialogFail(context),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  LatLngBounds _createBounds() {
    List<LatLng> positions;
    positions.add(widget.latLng);
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }
}
