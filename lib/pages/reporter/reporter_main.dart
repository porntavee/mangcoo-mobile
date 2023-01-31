import 'dart:convert';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/pages/reporter/reporter_list_category.dart';
import 'package:wereward/pages/reporter/reporter_list_category_disaster.dart';
import 'package:wereward/pages/reporter/reporter_map.dart';
import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/pages/reporter/reporter_history_list.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReporterMain extends StatefulWidget {
  ReporterMain({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ReporterMain createState() => _ReporterMain();
}

class _ReporterMain extends State<ReporterMain> {
  final storage = new FlutterSecureStorage();
  Future<dynamic> _futureCount;
  Future<dynamic> _futureOrganization;
  Future<dynamic> _futureBanner;

  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch;
  String category;

  List<dynamic> _dataOrganization = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    read();
    super.initState();
  }

  read() async {
    _futureCount = postDio('${server}m/v2/Reporter/count', {});
    _futureOrganization =
        postDio('${server}m/v2/register/organization/read', {});

    _futureBanner = postDio('${reporterBannerApi}read', {
      'skip': 0,
      'limit': 50,
      'reporterPage': true
      // 'profileCode': profileCode,
    });

    var value = await storage.read(key: 'dataUserLoginDDPM');
    var data = json.decode(value);

    setState(() {
      _dataOrganization =
          data['countUnit'] != '' ? json.decode(data['countUnit']) : [];
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    read();
    _refreshController.refreshCompleted();
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => Menu()),
    // );
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => Menu(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
  }

  void _handleHistory() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporterHistoryList(
          title: 'ประวัติการแจ้งข่าว',
          username: user['username'],
        ),
      ),
    );
    read();
  }

  void _handleMap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporterMap(
          title: 'แผนที่ข่าว',
        ),
      ),
    );
    read();
  }

  void _handleReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporterListCategory(
          title: 'แจ้งเหตุ / แจ้งข่าว',
        ),
      ),
    );
    read();
  }

  void _handleReportDisasterHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporterListCategoryDisaster(
          title: 'เหตุสาธารณภัย',
        ),
      ),
    );
    read();
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
        backgroundColor: Colors.white,
        appBar: header(
          context,
          title: widget.title,
          isShowLogo: false,
          isCenter: true,
          // isButtonRight: true,
          // rightButton: () => _handleClickMe(),
          // menu: 'reporter',
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: WaterDropHeader(
              complete: Container(
                child: Text(''),
              ),
              completeDuration: Duration(milliseconds: 0),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(
                    'รายงานสาธารณภัย',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 25,
                      fontFamily: 'Kanit',
                      color: Color.fromRGBO(0, 0, 0, 0.6),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var i = 0; i < _dataOrganization.length; i++)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_dataOrganization[i]['status'] == 'A')
                              Text(
                                _callSetOrganizationText(_dataOrganization[i]),
                                // " " +
                                // _dataOrganization[i]['titleLv5'].toString() ?? '',
                                style: TextStyle(
                                  fontSize: 13.00,
                                  fontFamily: 'Kanit',
                                  color: Color(
                                    0xFF000070,
                                  ),
                                ),
                                maxLines: 5,
                                textAlign: TextAlign.start,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    _handleReportDisasterHistory();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                'assets/images/reporter_total.png',
                              ),
                            ),
                          ),
                          height: 150.0,
                        ),
                        Container(
                          height: 150.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                'assets/images/background_reporter_main.png',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 100.0,
                            left: 10.0,
                          ),
                          alignment: Alignment.bottomLeft,
                          child: _buildCount(),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 125.0,
                            left: 10.0,
                          ),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'เหตุสาธารณภัย',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              fontFamily: 'Kanit',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          _handleReport();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3.3,
                          // margin: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Stack(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                      'assets/images/reporter_news.png',
                                    ),
                                  ),
                                ),
                                height: 200.0,
                              ),
                              Container(
                                height: 200.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                      'assets/images/background_reporter.png',
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 160.0,
                                  left: 5.0,
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'แจ้งข่าว / แจ้งเหตุ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 175.0,
                                  left: 5.0,
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'เหตุสาธารณภัย',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 8,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _handleMap();
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          width: MediaQuery.of(context).size.width / 3.3,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                      'assets/images/reporter_map.png',
                                    ),
                                  ),
                                ),
                                height: 200.0,
                              ),
                              Container(
                                height: 200.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                      'assets/images/background_reporter.png',
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 160.0,
                                  left: 5.0,
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'แผนที่ข่าว',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 175.0,
                                  left: 5.0,
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'เหตุสาธารณภัย',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 8,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _handleHistory();
                        },
                        child: Container(
                          // margin: EdgeInsets.symmetric(horizontal: 10.0),
                          width: MediaQuery.of(context).size.width / 3.3,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                      'assets/images/reporter_history.png',
                                    ),
                                  ),
                                ),
                                height: 200.0,
                              ),
                              Container(
                                height: 200.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                      'assets/images/background_reporter.png',
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 160.0,
                                  left: 5.0,
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'ประวัติการแจ้งข่าว',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 175.0,
                                  left: 5.0,
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'เหตุสาธารณภัย',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 8,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  _buildCount() {
    return FutureBuilder<dynamic>(
        future: _futureCount,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Text(
              snapshot.data['total'].toString(),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 25,
                fontFamily: 'Kanit',
                color: Colors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                color: Colors.white,
                child: dialogFail(context, reloadApp: true),
              ),
            );
          } else {
            return Center(
              child: Container(),
            );
          }
        });
  }

  _callSetOrganizationText(param) {
    var lv0 = param['titleLv0'];
    var lv1 = param['titleLv1'] == null ? '' : param['titleLv1'];
    var lv2 = param['titleLv2'] == null ? '' : param['titleLv2'];
    var lv3 = param['titleLv3'] == null ? '' : param['titleLv3'];
    var lv4 = param['titleLv4'] == null ? '' : param['titleLv4'];

    return '$lv0 $lv1 $lv2 $lv3 $lv4';
  }
}
