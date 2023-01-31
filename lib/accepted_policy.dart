import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_html/flutter_html.dart';

import 'widget/header.dart';

class AcceptedPolicyPage extends StatefulWidget {
  @override
  _AcceptedPolicyPageState createState() => _AcceptedPolicyPageState();
}

class _AcceptedPolicyPageState extends State<AcceptedPolicyPage> {
  Future<dynamic> futureModel;
  ScrollController scrollController = new ScrollController();
  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPolicy();
  }

  _callRead() {
    futureModel = postDio('${server}m/policy/readAccept', {
      "category": "marketing",
    });
  }

  _buildPolicy() {
    return Scaffold(
      appBar: header2(
        context,
        title: 'เงื่อนไขและข้อกำหนดการใช้งาน',
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                padding: EdgeInsets.only(
                  left: 15,
                  top: 15,
                  right: 15,
                  bottom: 15,
                ),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          snapshot.data[index]['title'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Html(
                        data: snapshot.data[index]['description'],
                      ),
                    ],
                  );
                });
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                // padding: const EdgeInsets.all(10.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    card(snapshot.data),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                color: Colors.white,
                child: dialogFail(context, reloadApp: false),
              ),
            );
          } else {
            return Center(
              child: Container(),
            );
          }
        },
      ),
    );
  }

  card(dynamic model) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
          child: formContentStep1(model)),
    );
  }

  formContentStep1(dynamic model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var item in model)
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      item['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  new Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  new Html(
                    data: item['description'].toString(),
                    onLinkTap: (String url, RenderContext context,
                        Map<String, String> attributes, element) {
                      launch(url);
                      // open url in a webview
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
