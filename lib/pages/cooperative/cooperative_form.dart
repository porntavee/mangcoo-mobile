import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';

// import 'package:wereward/component/downloadFile.dart';
import 'package:wereward/component/pdf_viewer_page.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/services.dart';
import 'package:wereward/shared/extension.dart';

class CooperativeForm extends StatefulWidget {
  CooperativeForm({Key key, @required this.code, this.model, this.urlComment})
      : super(key: key);
  final String code;
  final dynamic model;
  final String urlComment;

  @override
  _CooperativeDetailPageState createState() =>
      _CooperativeDetailPageState(code: code);
}

class _CooperativeDetailPageState extends State<CooperativeForm> {
  _CooperativeDetailPageState({this.code});

  Future<dynamic> _futureModel;

  String code;

  @override
  void initState() {
    super.initState();
    _futureModel = post(
      '${cooperativeApi}read',
      {'skip': 0, 'limit': 1, 'code': widget.code},
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
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
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: () => {
            Navigator.pop(context),
          },
          child: Icon(Icons.close),
          backgroundColor: Color(0xFFFF7514),
        ),
        body: FutureBuilder<dynamic>(
          future: _futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return myContent(
                snapshot.data[0],
              );
            } else {
              if (widget.model != null) {
                return myContent(
                  widget.model,
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        // overflow: Overflow.visible,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 540,
                                width: double.infinity,
                              ),
                              Container(
                                height: 540,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 60.0,
                              ),
                              Container(
                                height: 110,
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: 10.0, right: 20.0, top: 10.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontFamily: 'Kanit',
                                      ),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontFamily: 'Kanit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                width: 400.0,
                                padding:
                                    EdgeInsets.only(left: 90.0, right: 90.0),
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  child: Container(
                                    alignment: Alignment(1, 1),
                                    child: MaterialButton(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      onPressed: () {},
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            child: new Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Image.asset(
                                                'assets/images/book.png',
                                                height: 5.0,
                                                width: 5.0,
                                              ),
                                            ),
                                            width: 35.0,
                                            height: 35.0,
                                          ),
                                          Text(
                                            'ดาว์นโหลด',
                                            style: TextStyle(
                                              color: Color(0xFFFF7514),
                                              fontFamily: 'Kanit',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  myContent(dynamic model) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            // overflow: Overflow.visible,
            children: [
              Stack(
                children: [
                  Container(
                    height: 540,
                    width: double.infinity,
                    child: loadingImageNetwork(
                      model['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                    // Image.network(
                    //     model['imageUrl'],
                    //     fit: BoxFit.cover,
                    //   ),
                  ),
                  Container(
                    height: 540,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 60.0,
                  ),
                  loadingImageNetwork(
                    model['imageUrl'],
                    fit: BoxFit.cover,
                    height: 334,
                    width: 25,
                  ),
                  // Image.network(model['imageUrl'], height: 334, width: 250),
                  Container(
                    height: 110,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0),
                    child: Column(
                      children: [
                        Text(
                          model['title'],
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontFamily: 'Kanit',
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dateStringToDate(model['createDate']),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: 400.0,
                    padding: EdgeInsets.only(left: 90.0, right: 90.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      child: Container(
                        alignment: Alignment(1, 1),
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width,
                          onPressed: () {
                            // launchURL(model['fileUrl']);
                            // launchInWebViewWithJavaScript(model['fileUrl']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // builder: (context) => FlutterDemo(storage: CounterStorage()),
                                builder: (context) => PdfViewerPage(
                                  path: model['fileUrl'],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                child: new Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    'assets/images/book.png',
                                    height: 5.0,
                                    width: 5.0,
                                  ),
                                ),
                                width: 35.0,
                                height: 35.0,
                              ),
                              Text(
                                'ดาวน์โหลด',
                                style: TextStyle(
                                  color: Color(0xFFFF7514),
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Column(
            children: [
              TextDetail(
                  title: 'รายละเอียด',
                  value: '',
                  fsTitle: 20.0,
                  fsValue: 14.0,
                  color: Colors.black),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: 380,
                padding: EdgeInsets.only(left: 10.0, top: 5, right: 10.0),
                alignment: Alignment.topLeft,
                child: Html(
                  data: model['description'] != '' ? model['description'] : '',
                  onLinkTap: (String url, RenderContext context,
                      Map<String, String> attributes, element) {
                    launch(url);
                    // open url in a webview
                  },
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TextDetail extends StatelessWidget {
  TextDetail(
      {Key key,
      this.title,
      this.value,
      this.fsTitle,
      this.fsValue,
      this.color});

  final String title;
  final String value;
  final double fsTitle;
  final double fsValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 140,
          padding: EdgeInsets.only(left: 10.0, top: 5, right: 10.0),
          alignment: Alignment.topLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: fsTitle,
              color: color,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 10.0, top: 5),
            child: Text(
              value,
              style: TextStyle(
                fontSize: fsValue,
                color: color,
                fontFamily: 'Kanit',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
