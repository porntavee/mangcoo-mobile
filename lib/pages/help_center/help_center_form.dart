import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/shared/api_provider.dart';

class HelpCenterForm extends StatefulWidget {
  HelpCenterForm({Key key, this.model}) : super(key: key);
  final dynamic model;

  @override
  HelpCenterDetailPageState createState() => HelpCenterDetailPageState();
}

class HelpCenterDetailPageState extends State<HelpCenterForm> {
  HelpCenterDetailPageState();

  Future<dynamic> futureModel;

  ScrollController scrollController = new ScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _callread();
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _callread() {
    futureModel = postDio(
        server + "m/helpCenter/gallery/read", {'code': widget.model['code']});
  }

  _image() {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Container(
                height: 200,
                width: 200,
                padding: EdgeInsets.only(bottom: 10),
                child: Image.network(
                  snapshot.data[index]['imageUrl'],
                ),
              );
            },
          );
        } else
          return Container();
      },
    );
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
        appBar: header2(
          context,
          title: 'ศูนย์ช่วยเหลือ',
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    // alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                    child: Text(
                      widget.model['title'],
                      style: new TextStyle(
                        fontSize: 18,
                        color: Color(0XFF000000),
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    // alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      '  ${dateStringToDate(widget.model['createDate'])} FAQ',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    //  Text(
                    //   '${widget.model['docDate']} FAQ',
                    //   style: new TextStyle(
                    //     fontSize: 13,
                    //     color: Color(0XFF707070),
                    //     fontWeight: FontWeight.normal,
                    //     fontFamily: 'Kanit',
                    //   ),
                    // ),
                  ),
                  Container(
                    // alignment: Alignment.centerLeft,
                    // padding: EdgeInsets.only(left: 15, right: 15),
                    child: Html(
                      data: widget.model['description'] != ''
                          ? widget.model['description']
                          : '',
                      onLinkTap: (String url, RenderContext context,
                          Map<String, String> attributes, element) {
                        launch(url);
                        // open url in a webview
                      },
                    ),
                  ),
                  _image(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
