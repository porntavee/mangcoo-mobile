import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/carousel_form.dart';
import 'package:wereward/component/link_url_in.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/material/loading_tween.dart';

class CarouselBanner extends StatefulWidget {
  CarouselBanner({Key key, this.model, this.url, this.height: 70})
      : super(key: key);

  final dynamic model;
  final String url;
  final double height;

  @override
  _CarouselBanner createState() => _CarouselBanner();
}

class _CarouselBanner extends State<CarouselBanner>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CarouselBanner> {
  final storage = new FlutterSecureStorage();
  final txtDescription = TextEditingController();
  int _current = 0;
  String profileCode = "";

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

  @override
  bool get wantKeepAlive => true;

  _getprofileCode() async {
    profileCode = await storage.read(key: 'profileCode10');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                          var codeReplae = "B" +
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
                            url: 'm/Banner/' + widget.url,
                            urlGallery: 'm/Banner/' + widget.url,
                          ),
                        ),
                      );
                    }
                  },
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: widget.height,
                      aspectRatio: 5.0,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: loadingImageNetwork(
                              document['imageUrl'],
                              fit: BoxFit.fill,
                              height: double.infinity,
                              width: double.infinity,
                            ),
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
                              ? Theme.of(context).accentColor
                              : Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: _current == index
                            ? Theme.of(context).accentColor
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
          return LoadingTween(height: 150);
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
  final storage = new FlutterSecureStorage();
  String profileCode = "";

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
                          var codeReplae = "B" +
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
                            url: widget.url,
                            urlGallery: widget.url,
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
