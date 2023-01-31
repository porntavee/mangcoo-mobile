import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/carousel_form.dart';
import 'package:wereward/component/carousel_rotation.dart';
import 'package:wereward/component/link_url_in.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wereward/component/gallery_view.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';

// ignore: must_be_immutable
class ContentReporter extends StatefulWidget {
  ContentReporter({
    Key key,
    this.code,
    this.url,
    this.model,
    this.urlGallery,
    this.urlRotation,
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;
  final String urlRotation;

  @override
  _ContentReporter createState() => _ContentReporter();
}

class _ContentReporter extends State<ContentReporter> {
  Future<dynamic> _futureModel;
  Future<dynamic> _futureRotation;

  // String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _futureModel =
        post(widget.url, {'skip': 0, 'limit': 1, 'code': widget.code});
    _futureRotation = postDio(widget.urlRotation, {'limit': 10});

    readGallery();
    // sharedApi();
  }

  Future<dynamic> readGallery() async {
    final result =
        await postObjectData('m/Reporter/gallery/read', {'code': widget.code});

    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);

        dataPro.add(
            item['imageUrl'] != null ? NetworkImage(item['imageUrl']) : null);
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
  }

  // Future<dynamic> sharedApi() async {
  //   final result = await postObjectData('configulation/shared/read',
  //       {'skip': 0, 'limit': 1, 'code': widget.code});

  //   if (result['status'] == 's') {
  //     setState(() {
  //       _urlShared = result['objectData']['description'].toString();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          // setState(() {
          //   urlImage = [snapshot.data[0].imageUrl];
          // });

          // print(
          //     '-----------------------------------${snapshot.data[0].toString()}---------------------------');
          return myContentReporter(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // return Container();
          return myContentReporter(
            widget.model,
          );
          // return myContentReporter(widget.model);
        }
      },
    );
  }

  myContentReporter(dynamic model) {
    print(model['latitude']);
    List image = [];
    List<ImageProvider> imagePro = [];
    return ListView(
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      children: [
        Container(
          // width: 500.0,
          color: Color(0xFFFFFFF),
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
          ),
        ),
        Container(
          // color: Colors.green,
          padding: EdgeInsets.only(
            right: 10.0,
            left: 10.0,
          ),
          margin: EdgeInsets.only(right: 50.0, top: 10.0),
          child: Text(
            '${model['title']}',
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: '${model['imageUrlCreateBy']}' != null
                        ? NetworkImage('${model['imageUrlCreateBy']}')
                        : null,
                    // child: Image.network(
                    //     '${snapshot.data[0]['imageUrlCreateBy']}'),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model['firstName']} ${model['lastName']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dateStringToDate(model['createDate']) + ' | ',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Html(
            data: model['description'],
            onLinkTap: (String url, RenderContext context,
                Map<String, String> attributes, element) {
              launch(url);
              // open url in a webview
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 300,
          width: double.infinity,
          child: model['latitude'] != '' && model['latitude'] != ''
              ? googleMap(double.parse(model['latitude']),
                  double.parse(model['longitude']))
              : Container(),
        ),
        SizedBox(height: 6),
        _buildRotation(),
      ],
    );
  }

  googleMap(double lat, double lng) {
    return GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 16,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      // onTap: _handleTap,
      markers: <Marker>[
        Marker(
          markerId: MarkerId('1'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ].toSet(),
    );
  }

  _buildRotation() {
    return Container(
      // padding: EdgeInsets.only(left: 15, right: 15, top: 5),
      child: CarouselRotation(
        model: _futureRotation,
        nav: (String path, String action, dynamic model, String code) {
          if (action == 'out') {
            launchInWebViewWithJavaScript(path);
            // launchURL(path);
          } else if (action == 'in') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarouselForm(
                  code: code,
                  model: model,
                  url: mainBannerApi,
                  urlGallery: bannerGalleryApi,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
