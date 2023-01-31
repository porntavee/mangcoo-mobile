import 'dart:convert';
import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';

class SettingNotificationPage extends StatefulWidget {
  @override
  _SettingNotificationPageState createState() =>
      _SettingNotificationPageState();
}

class _SettingNotificationPageState extends State<SettingNotificationPage> {
  final storage = new FlutterSecureStorage();

  String _username;

  Future<dynamic> futureModel;

  ScrollController scrollController = new ScrollController();

  bool isSwitchedEventPage = false;
  bool isSwitchedContactPage = false;
  bool isSwitchedKnowledgePage = false;
  bool isSwitchedMainPage = false;
  bool isSwitchedNewsPage = false;
  bool isSwitchedPoiPage = false;
  bool isSwitchedPollPage = false;
  bool isSwitchedPrivilegePage = false;
  bool isSwitchedReporterPage = false;
  bool isSwitchedWelfarePage = false;
  bool isSwitchedCooperativeFormPage = false;
  bool isSwitchedWarningPage = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    futureModel = readNotification();
    super.initState();
  }

  Future<dynamic> readNotification() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value);
    if (user['code'] != '') {
      setState(() {
        _username = user['username'] ?? '';
      });
    }
    final result = await postObjectData('m/register/notification/read', {
      'username': _username,
    });

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataNotificationDDPM',
        value: jsonEncode(result['objectData']),
      );

      setState(() {
        isSwitchedEventPage = result['objectData']['eventPage'];
        isSwitchedContactPage = result['objectData']['contactPage'];
        isSwitchedKnowledgePage = result['objectData']['knowledgePage'];
        isSwitchedMainPage = result['objectData']['mainPage'];
        isSwitchedNewsPage = result['objectData']['newsPage'];
        isSwitchedPoiPage = result['objectData']['poiPage'];
        isSwitchedPollPage = result['objectData']['pollPage'];
        isSwitchedPrivilegePage = result['objectData']['privilegePage'];
        isSwitchedReporterPage = result['objectData']['reporterPage'];
        isSwitchedWelfarePage = result['objectData']['welfarePage'];
        isSwitchedCooperativeFormPage =
            result['objectData']['cooperativeFormPage'];
        // isSwitchedWarningPage = result['objectData']['warningPage'];
      });
    }
  }

  Future<dynamic> updateNotication() async {
    var value = await storage.read(key: 'dataNotificationDDPM');
    var data = json.decode(value);
    data['eventPage'] = isSwitchedEventPage;
    data['contactPage'] = isSwitchedContactPage;
    data['knowledgePage'] = isSwitchedKnowledgePage;
    data['mainPage'] = isSwitchedMainPage;
    data['newsPage'] = isSwitchedNewsPage;
    data['poiPage'] = isSwitchedPoiPage;
    data['pollPage'] = isSwitchedPollPage;
    data['privilegePage'] = isSwitchedPrivilegePage;
    data['reporterPage'] = isSwitchedReporterPage;
    data['welfarePage'] = isSwitchedWelfarePage;
    data['cooperativeFormPage'] = isSwitchedCooperativeFormPage;
    data['warningPage'] = isSwitchedWarningPage;

    final result = await postObjectData('m/Register/notification/update', data);

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataNotificationDDPM',
        value: jsonEncode(result['objectData']),
      );

      setState(() {
        isSwitchedEventPage = result['objectData']['eventPage:'] ?? '';
        isSwitchedContactPage = result['objectData']['contactPage:'] ?? '';
        isSwitchedKnowledgePage = result['objectData']['knowledgePage:'] ?? '';
        isSwitchedMainPage = result['objectData']['mainPage'] ?? '';
        isSwitchedNewsPage = result['objectData']['newsPage'] ?? '';
        isSwitchedPoiPage = result['objectData']['poiPage'] ?? '';
        isSwitchedPollPage = result['objectData']['pollPage'] ?? '';
        isSwitchedPrivilegePage = result['objectData']['privilegePage'] ?? '';
        isSwitchedReporterPage = result['objectData']['reporterPage'] ?? '';
        isSwitchedWelfarePage = result['objectData']['welfarePage'] ?? '';
        isSwitchedCooperativeFormPage =
            result['objectData']['cooperativeFormPage'] ?? '';
      });
    }
  }

  void goBack() async {
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => UserInformationPage(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
    Navigator.pop(context, false);
    // // Navigator.of(context).push(
    // //   MaterialPageRoute(
    // //     builder: (context) => UserInformationPage(),
    // //   ),
    // // );
  }

  card() {
    return Card(
      color: Colors.white,
      // color: Theme.of(context).backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(10), child: contentCard()),
    );
  }

  contentCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          'ตั้งค่าการแจ้งเตือน',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.all(5),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         flex: 5,
        //         child: _buildText('ระบบแจ้งเตือน'),
        //       ),
        //       Expanded(
        //         child: Switch(
        //           value: isSwitchedMainPage,
        //           onChanged: (value) {
        //             print(value);
        //             setState(() {
        //               isSwitchedMainPage = value;
        //             });
        //             updateNotication();
        //           },
        //           activeTrackColor: Theme.of(context).accentColor,
        //           activeColor: Color(0xFFFFFFFF),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        // _buildLine(),
        Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildText('ข่าวสารประชาสัมพันธ์'),
              ),
              Expanded(
                child: Switch(
                  value: isSwitchedNewsPage,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      isSwitchedNewsPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Theme.of(context).accentColor,
                  activeColor: Color(0xFFFFFFFF),
                ),
              )
            ],
          ),
        ),
        _buildLine(),
        Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildText('ปฏิทินกิจกรรม'),
              ),
              Expanded(
                child: Switch(
                  value: isSwitchedEventPage,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      isSwitchedEventPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Theme.of(context).accentColor,
                  activeColor: Color(0xFFFFFFFF),
                ),
              )
            ],
          ),
        ),
        _buildLine(),
        // Padding(
        //   padding: EdgeInsets.all(5),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         flex: 5,
        //         child: _buildText('อาสาควรรู้'),
        //       ),
        //       Expanded(
        //         child: Switch(
        //           value: isSwitchedKnowledgePage,
        //           onChanged: (value) {
        //             print(value);
        //             setState(() {
        //               isSwitchedKnowledgePage = value;
        //             });
        //             updateNotication();
        //           },
        //           activeTrackColor: Theme.of(context).accentColor,
        //           activeColor: Color(0xFFFFFFFF),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        // _buildLine(),
        Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildText('สิทธิประโยชน์'),
              ),
              Expanded(
                child: Switch(
                  value: isSwitchedPrivilegePage,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      isSwitchedPrivilegePage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Theme.of(context).accentColor,
                  activeColor: Color(0xFFFFFFFF),
                ),
              )
            ],
          ),
        ),
        _buildLine(),
        Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildText('สถานที่น่าสนใจ'),
              ),
              Expanded(
                child: Switch(
                  value: isSwitchedPoiPage,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      isSwitchedPoiPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Theme.of(context).accentColor,
                  activeColor: Color(0xFFFFFFFF),
                ),
              )
            ],
          ),
        ),
        _buildLine(),
      ],
    );
  }

  _buildText(param) {
    return Text(
      param,
      style: new TextStyle(
        fontSize: 13.0,
        //color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
      ),
    );
  }

  _buildSwtich({String title, bool model}) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: new TextStyle(
                fontSize: 13.0,
                //color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
          ),
          Expanded(
            child: Switch(
              value: model,
              onChanged: (value) {
                print(value);
                setState(() {
                  model = value;
                });
                updateNotication();
              },
              activeTrackColor: Theme.of(context).accentColor,
              activeColor: Color(0xFFFFFFFF),
            ),
          )
        ],
      ),
    );
  }

  _buildLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E2E2),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  rowContentButton(String urlImage, String title) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
            child: new Padding(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(
                urlImage,
                height: 5.0,
                width: 5.0,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              //color: Color(0xFFFFFFFF),
            ),
            width: 30.0,
            height: 40.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.733,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              title,
              style: new TextStyle(
                fontSize: 13.0,
                //color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Image.asset(
              "assets/logo/icons/Group6232.png",
              height: 20.0,
              width: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context),
            ),
          );
        else
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
                title: 'ตั้งค่าการแจ้งเตือน',
              ),
              backgroundColor: Colors.white,
              body: Container(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  // padding: EdgeInsets.only(top: 10),
                  children: <Widget>[
                    new Column(
                      // alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          // alignment: Alignment.topCenter,
                          margin: EdgeInsets.only(
                            left: 45.0,
                            right: 15.0,
                          ),
                          child: contentCard(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
      },
    );
  }
}
