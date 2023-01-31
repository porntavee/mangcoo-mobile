import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import '../../home_mart.dart';
import '../blank_page/toast_fail.dart';

class PolicyIdentityVerificationPage extends StatefulWidget {
  PolicyIdentityVerificationPage({Key key, @required this.username})
      : super(key: key);
  final String username;

  @override
  _PolicyIdentityVerificationPageState createState() =>
      _PolicyIdentityVerificationPageState();
}

class _PolicyIdentityVerificationPageState
    extends State<PolicyIdentityVerificationPage> {
  final storage = new FlutterSecureStorage();

  List<dynamic> _dataPolicy = [];
  Future<dynamic> futureModel;
  ScrollController scrollController = new ScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      futureModel = postDio(server + "m/policy/read", {
        "category": "application",
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logout(context);
        // Navigator.pop(context, false);
        return true;
      },

      // onWillPop: _onBackPressed,
      child: GestureDetector(
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
          body: FutureBuilder<dynamic>(
            future: futureModel,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
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
                return Center(child: dialogFail(context));
              } else {
                return Container();
              }
            },
          ),
        ),
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
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10.0,
              right: 10.0,
              bottom: 10.0),
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
                    // onImageTap: (src) {
                    //   // Display the image in large form.
                    // },
                  ),
                  // if (item['isRequired'])
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                              color: item['agree'] == true
                                  ? Color(0xFFFF7514)
                                  : Colors.white,
                            ),
                          ),
                          color: item['agree'] == true
                              ? Color(0xFFFF7514)
                              : Colors.white,
                          textColor: item['agree'] == true
                              ? Colors.white
                              : Color(0xFFFF7514),
                          onPressed: () {
                            setState(() {
                              item['noAgree'] = false;
                              item['agree'] = true;
                              item['isActive'] = true;
                            });
                          },
                          child: Text(
                            'ยินยอม',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        item['isRequired']
                            ? Container()
                            : RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(
                                    color: item['noAgree'] == true
                                        ? Color(0xFFFF7514)
                                        : Colors.white,
                                  ),
                                ),
                                color: item['noAgree'] == true
                                    ? Color(0xFFFF7514)
                                    : Colors.white,
                                textColor: item['noAgree'] == true
                                    ? Colors.white
                                    : Color(0xFFFF7514),
                                onPressed: () {
                                  setState(() {
                                    item['agree'] = false;
                                    item['noAgree'] = true;
                                    item['isActive'] = false;
                                  });
                                },
                                child: Text(
                                  'ไม่ยินยอม',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Kanit',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(
          height: 30,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(
                  color: Color(0xFFFF7514),
                ),
              ),
              color: Color(0xFFFF7514),
              textColor: Colors.white,
              onPressed: () {
                sendPolicy(model);
              },
              child: Text(
                'ตกลง',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(width: 10),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(
                  color: Color(0xFFFF7514),
                ),
              ),
              color: Colors.white,
              textColor: Color(0xFFFF7514),
              onPressed: () {
                logout(context);
                // Navigator.pop(context, false);
              },
              child: Text(
                'กลับ',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Future<dynamic> updatePolicy(dynamic model) async {
    if (model.length > 0) {
      for (int i = 0; i < model.length; i++) {
        await postDio(server + "m/policy/create", {
          "reference": model[i]['code'].toString(),
          "isActive": model[i]['isActive'],
        });
      }
    }

    // return Navigator.pop(context, true);
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeMartPage(),
      ),
    );
  }

  Future<dynamic> sendPolicy(dynamic model) async {
    var index = model
        .indexWhere((c) => c['isActive'] == false && c['isRequired'] == true);

    if (index == -1) {
      updatePolicy(model);
    } else {
      return toastFail(context, text: 'กรุณาตรวจสอบและยอมรับนโยบาย');
    }
  }

  void goBack() async {
    Navigator.pop(context, false);
  }
}
