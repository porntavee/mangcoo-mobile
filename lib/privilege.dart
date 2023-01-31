import 'dart:async';
import 'dart:convert';
import 'package:wereward/component/carousel_rotation_new.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/material/form_content.dart';
import 'package:wereward/component/menu/grid_content.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/pages/main_popup/dialog_main_popup.dart';
import 'package:flutter/material.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PrivilegePage extends StatefulWidget {
  @override
  _PrivilegePageState createState() => _PrivilegePageState();
}

class _PrivilegePageState extends State<PrivilegePage> {
  final storage = new FlutterSecureStorage();

  Future<dynamic> _futureModel;
  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategory;
  Future<dynamic> _futureForceAds;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int _limit = 10;
  var tempData = List<dynamic>();

  @override
  void initState() {
    _callRead();
    getForceAds();
    super.initState();
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
        // appBar: _buildHeader(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor,
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              _buildHead(),
              Expanded(child: _buildFutureBuilder()),
            ],
          ),
        ),
      ),
    );
  }

  _buildHead() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        // height: 120,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      'สิทธิพิเศษเฉพาะคุณ',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: KeySearch(
                      onKeySearchChange: (String val) {
                        setState(
                          () {
                            keySearch = val;
                          },
                        );
                        _onLoading();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              CategorySelector2(
                model: _futureCategory,
                onChange: (String val) {
                  setState(
                    () => {category = val, _limit = 10},
                  );
                  _onLoading();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildFutureBuilder() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          // return _screen(snapshot.data);
          return _buildSmartRefresher(_screen(snapshot.data));
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: false),
            ),
          );
        } else {
          return _buildSmartRefresher(
            _screen(tempData),
          );
        }
      },
    );
  }

  _screen(dynamic model) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ListView(
      children: [
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Carousel2(model: _futureBanner, url: 'privilege/'),
          ),
        ),
        SizedBox(height: 20),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 15),
          margin: EdgeInsets.only(bottom: 5),
          child: Text(
            'รายการทั้งหมด',
            style: TextStyle(
              color: themeChange.darkTheme
                  ? Colors.white
                  : Theme.of(context).primaryColor,
              fontSize: 13,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        GridContent1(
          model: _futureModel,
          cardHeight: 100,
          navigationForm: (dynamic model) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormContent(
                  api: 'privilege',
                  model: model,
                  urlRotation: rotationPrivilegeApi,
                ),
              ),
            ).then((value) => _onRefresh());
          },
        ),
      ],
    );
  }

  _buildSmartRefresher(Widget child) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(
        complete: Container(
          child: Text(''),
        ),
        completeDuration: Duration(milliseconds: 0),
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
    setState(() {
      _limit = 10;
    });
    _callRead();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
    });

    _callRead();
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.loadComplete();
  }

  _callRead() {
    _futureBanner = postDio('${privilegeBannerApi}read', {'limit': 10});
    _futureModel = postDio('${server}m/privilege/read',
        {"category": category, "limit": _limit, "keySearch": keySearch});
    _futureForceAds = postDio(
        '${forceAdsApi}read', {'skip': 0, 'limit': 10, 'privilegePage': true});
    _futureCategory = postDioCategory(
      '${privilegeCategoryApi}read',
      {
        'skip': 0,
        'limit': 100,
      },
    );

    for (var i = 0; i < 10; i++) {
      tempData.add({'title': '', 'imageUrl': ''});
    }
  }

  Future<dynamic> showForceAds() async {
    var profileUserName = await storage.read(key: 'profileUserName');

    var valueStorage = await storage.read(key: 'privilegeDDPM');
    var dataValue;
    if (valueStorage != null) {
      dataValue = json.decode(valueStorage);
    } else {
      dataValue = null;
    }

    var now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    if (dataValue != null) {
      var index = dataValue.indexWhere(
        (c) =>
            c['username'] == profileUserName &&
            c['date'] == DateFormat("ddMMyyyy").format(date).toString() &&
            c['boolean'] == "true",
      );

      if (index == -1) {
        return showDialog(
          barrierDismissible: false, // close outside
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: MainPopupDialog(
                model: _futureForceAds,
                type: 'privilege',
                username: profileUserName,
              ),
            );
          },
        );
      }
    } else {
      return showDialog(
        barrierDismissible: false, // close outside
        context: context,
        builder: (_) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: MainPopupDialog(
              model: _futureForceAds,
              type: 'privilege',
              username: profileUserName,
            ),
          );
        },
      );
    }
  }

  getForceAds() async {
    var result = await postDio(
        '${forceAdsApi}read', {'skip': 0, 'limit': 100, 'privilegePage': true});
    if (result.length > 0) {
      showForceAds();
    }
  }
  //
}
