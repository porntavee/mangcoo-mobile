import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/gallery_view.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// ignore: must_be_immutable
class ContentNotification extends StatefulWidget {
  ContentNotification({
    Key key,
    this.code,
    this.url,
    this.model,
    this.urlGallery,
    this.pathShare,
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;
  final String pathShare;

  @override
  _ContentNotification createState() => _ContentNotification();
}

class _ContentNotification extends State<ContentNotification> {
  Future<dynamic> _futureModel;

  String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    super.initState();
    _futureModel =
        post(widget.url, {'skip': 0, 'limit': 1, 'code': widget.code});

    readGallery();
  }

  Future<dynamic> readGallery() async {
    final result = await postObjectData(
        'm/notification/gallery/read', {"code": widget.code});

    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);

        dataPro.add(
          item['imageUrl'] != null ? NetworkImage(item['imageUrl']) : null,
        );
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
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
          return myContentNotification(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return myContentNotification(
            widget.model,
          );
          // return myContentNotification(widget.model);
        }
      },
    );
  }

  myContentNotification(dynamic model) {
    return ListView(
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      children: [
        Container(
          // width: 500.0,
          // color: Color(0xFFFFFFF),
          color: Colors.white,
          child: GalleryView(
            imageUrl: [...urlImage],
            imageProvider: [...urlImageProvider],
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
                    child: model['userList'] != null &&
                            model['userList'].length > 0
                        ? CircleAvatar(
                            backgroundImage:
                                '${model['userList'][0]['imageUrl']}' != null
                                    ? NetworkImage(
                                        '${model['userList'][0]['imageUrl']}')
                                    : null,
                          )
                        : Container(),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model['userList'] != null &&
                                  model['userList'].length > 0
                              ? '${model['userList'][0]['firstName']} ${model['userList'][0]['lastName']}'
                              : '${model['createBy']}',
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
                                  ? dateStringToDate(model['createDate'])
                                  : '',
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
            // onImageTap: (src) {
            //   // Display the image in large form.
            // },
          ),
        ),
        Container(
          height: 10,
        ),
        model['fileUrl'] != '' ? fileUrl(model) : Container(),
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
}
