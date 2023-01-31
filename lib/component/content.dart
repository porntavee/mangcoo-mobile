import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/carousel_form.dart';
import 'package:wereward/component/carousel_rotation.dart';
import 'package:wereward/component/link_url_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wereward/component/gallery_view.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share/share.dart';
import 'package:wereward/shared/extension.dart';

// ignore: must_be_immutable
class Content extends StatefulWidget {
  Content({
    Key key,
    this.code,
    this.url,
    this.model,
    this.urlGallery,
    this.urlRotation,
    this.pathShare,
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;
  final String urlRotation;
  final String pathShare;

  @override
  _Content createState() => _Content();
}

class _Content extends State<Content> {
  Future<dynamic> _futureModel;
  Future<dynamic> _futureRotation;
  final storage = new FlutterSecureStorage();

  String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    super.initState();
    initFunc();
    sharedApi();

    readGallery();
  }

  initFunc() async {
    _futureModel = postDio(widget.url, {'limit': 1, 'code': widget.code});
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
        item['imageUrl'] != null ? NetworkImage(item['imageUrl']) : null,
      );
    }
    setState(() {
      urlImage = data;
      urlImageProvider = dataPro;
    });
    // }
  }

  Future<dynamic> sharedApi() async {
    await postConfigShare().then(
      (result) => {
        if (result['status'] == 'S')
          {
            setState(() {
              _urlShared = result['objectData']['description'];
            }),
          }
      },
    );
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
          return myContent(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Container();
          // return myContent(widget.model);
        }
      },
    );
  }

  myContent(dynamic model) {
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
          // color: Color(0xFFFFFFF),
          color: Colors.white,
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(model['imageUrlCreateBy']),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model['createBy']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w300,
                          ),
                          maxLines: 3,
                        ),
                        Row(
                          children: [
                            Text(
                              model['createDate'] != null
                                  ? dateStringToDate(model['createDate']) +
                                      ' | '
                                  : '',
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.24,
                    child: Container(
                      width: 100.0,
                      height: 35.0,
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
                    ),
                  ),
                ],
              ),
            ),
            // Container(
            //   width: 74.0,
            //   height: 31.0,
            //   // decoration: BoxDecoration(
            //   //     image: DecorationImage(
            //   //       image: AssetImage('assets/images/share.png'),
            //   //     )),
            //   alignment: Alignment.centerRight,
            //   child: FlatButton(
            //     padding: EdgeInsets.all(0.0),
            //     onPressed: () {
            //       final RenderBox box = context.findRenderObject();
            //       Share.share(
            //         _urlShared +
            //             widget.pathShare +
            //             '${model['code']}' +
            //             ' ${model['title']}',
            //         subject: '${model['title']}',
            //         sharePositionOrigin:
            //             box.localToGlobal(Offset.zero) & box.size,
            //       );
            //     },
            //     child: Image.asset('assets/images/share.png'),
            //   ),
            // )
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
        Container(
          height: 10,
        ),
        model['linkUrl'] != '' && model['textButton'] != ''
            ? linkButton(model)
            : Container(),
        Container(
          height: 10,
        ),
        model['fileUrl'] != '' ? fileUrl(model) : Container(),
        SizedBox(height: 10),
        if (widget.urlRotation != '') _buildRotation()
      ],
    );
  }

  linkButton(dynamic model) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 45.0,
      padding: EdgeInsets.symmetric(horizontal: 80.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: Color(0xFFFF7514),
            ),
          ),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            onPressed: () {
              launchURL('${model['linkUrl']}');
            },
            child: Text(
              '${model['textButton']}',
              style: TextStyle(
                color: Color(0xFFFF7514),
                fontFamily: 'Kanit',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }

  fileUrl(dynamic model) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          launchURL('${model['fileUrl']}');
        },
        child: Text(
          'เปิดเอกสารแนบ',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14.0,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
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
