import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/carousel_form.dart';
import 'package:wereward/component/link_url_in.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CarouselRotationNew extends StatefulWidget {
  CarouselRotationNew({Key key, this.model, this.url}) : super(key: key);

  final Future<dynamic> model;
  final String url;

  @override
  _CarouselRotationNew createState() => _CarouselRotationNew();
}

class _CarouselRotationNew extends State<CarouselRotationNew> {
  final txtDescription = TextEditingController();
  int _current = 0;
  String profileCode = "";
  final storage = new FlutterSecureStorage();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  final List<String> imgList = [];

  @override
  void initState() {
    _getprofileCode();
    super.initState();
  }

  _getprofileCode() async {
    profileCode = await storage.read(key: 'profileCode10');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                InkWell(
                  onTap: () {
                    if (snapshot.data[_current]['action'] == 'out') {
                      if (snapshot.data[_current]['isPostHeader']) {
                        if (profileCode != '') {
                          var path = snapshot.data[_current]['linkUrl'];
                          var code = snapshot.data[_current]['code'];
                          var splitCheck = path.split('').reversed.join();
                          if (splitCheck[0] != "/") {
                            path = path + "/";
                          }
                          var codeReplae = "R" +
                              profileCode.replaceAll('-', '') +
                              code.replaceAll('-', '');
                          launchInWebViewWithJavaScript('$path$codeReplae');
                          // launchURL(path);
                        }
                      } else
                        launchInWebViewWithJavaScript(
                            snapshot.data[_current]['linkUrl']);
                    } else if (snapshot.data[_current]['action'] == 'in') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarouselForm(
                            code: snapshot.data[_current]['code'],
                            model: snapshot.data[_current],
                            url: 'm/Rotation/' + widget.url,
                            urlGallery: 'm/Rotation/' + widget.url,
                          ),
                        ),
                      );
                    }
                  },
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 120,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: snapshot.data.map<Widget>(
                      (document) {
                        return new Container(
                          // margin: EdgeInsets.symmetric(
                          //   horizontal: 15,
                          // ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: loadingImageNetwork(
                                  document['imageUrl'],
                                  fit: BoxFit.fill,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snapshot.data.map<Widget>((url) {
                    int index = snapshot.data.indexOf(url);
                    return Container(
                      width: _current == index ? 7.5 : 7.5,
                      height: 7.5,
                      margin: _current == index
                          ? EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 1.0,
                            )
                          : EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 2.0,
                            ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: _current == index
                                ? Color(0xFFE64D22)
                                : Color(0xFFE64D22)),
                        borderRadius: BorderRadius.circular(5),
                        color: _current == index
                            ? Color(0xFFE64D22)
                            : Colors.transparent,
                        // : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                )
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }
}

class Carousel2 extends StatefulWidget {
  Carousel2({Key key, this.model, this.url}) : super(key: key);

  final Future<dynamic> model;
  final String url;

  @override
  _Carousel2 createState() => _Carousel2();
}

class _Carousel2 extends State<Carousel2> {
  final txtDescription = TextEditingController();
  int _current = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  final List<String> imgList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                InkWell(
                  onTap: () {
                    if (snapshot.data[_current]['action'] == 'out') {
                      launchInWebViewWithJavaScript(
                          snapshot.data[_current]['linkUrl']);
                    } else if (snapshot.data[_current]['action'] == 'in') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarouselForm(
                            code: snapshot.data[_current]['code'],
                            model: snapshot.data[_current],
                            url: 'm/Rotation/' + widget.url,
                            urlGallery: 'm/Rotation/' + widget.url,
                          ),
                        ),
                      );
                    }
                  },
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 120,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: snapshot.data.map<Widget>(
                      (document) {
                        return new Container(
                          // margin: EdgeInsets.symmetric(
                          //   horizontal: 15,
                          // ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: loadingImageNetwork(
                                  document['imageUrl'],
                                  fit: BoxFit.fill,
                                  height: 150,
                                  width: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snapshot.data.map<Widget>((url) {
                    int index = snapshot.data.indexOf(url);
                    return Container(
                      width: _current == index ? 7.5 : 7.5,
                      height: 7.5,
                      margin: _current == index
                          ? EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 1.0,
                            )
                          : EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 2.0,
                            ),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xFFE84C12)),
                        borderRadius: BorderRadius.circular(5),
                        color: _current == index
                            ? Color(0xFFE84C12)
                            : Colors.transparent,
                        // : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                )
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }
}
