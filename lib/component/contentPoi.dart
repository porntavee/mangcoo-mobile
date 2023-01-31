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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wereward/component/gallery_view.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:share/share.dart';
import 'package:wereward/shared/extension.dart';

// ignore: must_be_immutable
class ContentPoi extends StatefulWidget {
  ContentPoi({
    Key key,
    this.code,
    this.url,
    this.model,
    this.urlGallery,
    this.pathShare,
    this.urlRotation,
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;
  final String pathShare;
  final String urlRotation;

  @override
  _ContentPoi createState() => _ContentPoi();
}

class _ContentPoi extends State<ContentPoi> {
  Future<dynamic> _futureModel;
  Future<dynamic> _futureRotation;

  String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  Completer<GoogleMapController> _mapController = Completer();
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    initFunc();
    readGallery();
    sharedApi();
  }

  initFunc() async {
    _futureModel = postDio(
        widget.url + 'read', {'skip': 0, 'limit': 1, 'code': widget.code});
    _futureRotation = postDio(widget.urlRotation, {'limit': 10});
  }

  Future<dynamic> readGallery() async {
    final result = await postDio(widget.urlGallery, {'code': widget.code});

    // if (result['status'] == 'S') {
    List data = [];
    List<ImageProvider> dataPro = [];

    for (var item in result) {
      data.add(item['imageUrl']);

      dataPro.add(
          item['imageUrl'] != null ? NetworkImage(item['imageUrl']) : null);
    }
    setState(() {
      urlImage = data;
      urlImageProvider = dataPro;
    });
    // }
  }

  Future<dynamic> sharedApi() async {
    await postConfigShare().then((result) => {
          if (result['status'] == 'S')
            {
              setState(() {
                _urlShared = result['objectData']['description'];
              }),
            }
        });
  }

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
          return myContentPoi(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return myContentPoi(
            widget.model,
          );
          // return myContentPoi(widget.model);
        }
      },
    );
  }

  myContentPoi(dynamic model) {
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [
      model['imageUrl'] != null ? NetworkImage(model['imageUrl']) : null
    ];
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
                    backgroundImage: model['imageUrlCreateBy'] != null
                        ? NetworkImage(model['imageUrlCreateBy'])
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
                          model['createBy'],
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
                            Text(
                              'เข้าชม ' + '${model['view']}' + ' ครั้ง',
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
            Container(
              width: 74.0,
              height: 31.0,
              // decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage('assets/images/share.png'),
              //     )),
              alignment: Alignment.centerRight,
              child: FlatButton(
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  Share.share(
                    _urlShared +
                        widget.pathShare +
                        '${model['code']}' +
                        ' ${model['title']}',
                    subject: '${model['title']}',
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size,
                  );
                },
                child: Image.asset('assets/images/share.png'),
              ),
            )
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
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Text(
            'ที่ตั้ง',
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Text(
            model['address'] != '' ? model['address'] : '-',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        SizedBox(height: 10),
        if (widget.urlRotation != '') _buildRotation(),
        SizedBox(height: 10),
        Container(
          height: 400,
          width: double.infinity,
          child: googleMap(
              model['latitude'] != ''
                  ? double.parse(model['latitude'])
                  : 13.8462512,
              model['longitude'] != ''
                  ? double.parse(model['longitude'])
                  : 100.5234803),
        ),
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
