import 'dart:async';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

class ReporterMap extends StatefulWidget {
  ReporterMap({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ReporterMap createState() => _ReporterMap();
}

class _ReporterMap extends State<ReporterMap> {
  Completer<GoogleMapController> _mapController = Completer();

  final txtDescription = TextEditingController();
  bool hideSearch = true;
  String keySearch = '';
  String category = '';
  int _limit = 10;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<dynamic> _futureReporter;
  Future<dynamic> _future;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureReporter = post('${reporterApi}read', {'skip': 0, 'limit': 50});
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
      _futureReporter = post('${reporterApi}read', {
        'skip': 0,
        'limit': 50,
        // 'category': category,
        // "keySearch": keySearch
      });
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => Menu(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: header(context, goBack, title: widget.title),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(
                Icons.arrow_upward,
                color: Colors.transparent,
              ),
            ),
            controller: _refreshController,
            onLoading: _onLoading,
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.only(bottom: 10.0),
                  width: double.infinity,
                  child: googleMap(_futureReporter),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  googleMap(modelData) {
    List<Marker> _markers = <Marker>[];

    return FutureBuilder<dynamic>(
      future: modelData, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            snapshot.data
                .map(
                  (item) => item['latitude'] != '' && item['longitude'] != ''
                      ? _markers.add(
                          Marker(
                            markerId: MarkerId(item['code']),
                            position: LatLng(
                              double.parse(item['latitude']),
                              double.parse(item['longitude']),
                            ),
                            infoWindow: InfoWindow(
                              title: item['title'].toString(),
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        )
                      : null,
                )
                .toList();
          }
          //  var imagesBytes = _getimages("https://ddpm.we-builds.com/ddpm-document/images/reporter-categoty/reporter-categoty_204916307.jpg");
          //  print('----------------$imagesBytes---------------');
          return GoogleMap(
            myLocationEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(13.743894, 100.538592),
              zoom: 7,
            ),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(
                () => new EagerGestureRecognizer(),
              ),
            ].toSet(),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
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
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(),
          );
        }
      },
    );
  }

  _getimages(url) async {
    var request = await http.get(url);
    var dataByte = request.bodyBytes.buffer.asUint8List();
    return dataByte;
  }
}
