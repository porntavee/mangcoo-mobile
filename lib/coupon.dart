import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/component/material/form_content.dart';
import 'package:wereward/component/menu/list_content.dart';
import 'package:wereward/dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CouponPage extends StatefulWidget {
  @override
  _CouponPageState createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  Future<dynamic> _futureModelMyReward;
  Future<dynamic> _futureModelMyLike;
  Future<dynamic> _futureModelUsed;
  Future<dynamic> _futureModelExpired;
  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategory;
  List<dynamic> categoryList;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  var tempData = List<dynamic>();

  @override
  void initState() {
    categoryList = [
      {'title': 'คูปองของฉัน', 'value': '0'},
      // {'title': 'My Like', 'value': '1'},
      {'title': 'คูปองใช้แล้ว', 'value': '1'},
      {'title': 'คูปองหมดอายุ', 'value': '2'}
    ];
    selectedIndexCategory = 0;
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
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
        backgroundColor: themeChange.darkTheme
            ? Color(0xFF505050)
            : Theme.of(context).backgroundColor,
        // backgroundColor: Theme.of(context).backgroundColor,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              _buildHead(),
              Expanded(
                child: _buildSmartRefresher(
                  ListView(
                    children: _buildList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  _buildHead() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
        boxShadow: [
          new BoxShadow(
            color: Colors.grey[500],
            blurRadius: 20.0,
            spreadRadius: 1.0,
          )
        ],
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
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      'My Coupon',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _categorySelector(
                model: categoryList,
                onChange: (String val) {
                  setState(
                    () => {},
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

  _categorySelector({dynamic model, Function onChange}) {
    return Container(
      height: 25.0,
      // padding: EdgeInsets.only(left: 5.0, right: 5.0),
      // margin: EdgeInsets.symmetric(horizontal: 10.0),

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              // widget.onChange(model[index]['code']);
              setState(() {
                selectedIndexCategory = index;
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10),
              decoration: new BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
                borderRadius: new BorderRadius.circular(12.5),
                color: index == selectedIndexCategory
                    ? Colors.white
                    : Theme.of(context).accentColor,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 7.0,
                // vertical: 5.0,
              ),
              child: Text(
                model[index]['title'],
                style: TextStyle(
                  color: index == selectedIndexCategory
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  // decoration: index == selectedIndex
                  //     ? TextDecoration.underline
                  //     : null,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2,
                  fontFamily: 'Kanit',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _buildList() {
    Future<dynamic> _model;
    if (selectedIndexCategory == 0)
      _model = _futureModelMyReward;
    // else if (selectedIndexCategory == 1)
    //   _model = _futureModelMyLike;
    else if (selectedIndexCategory == 1)
      _model = _futureModelUsed;
    else if (selectedIndexCategory == 2) _model = _futureModelExpired;
    return <Widget>[
      SizedBox(height: 10),
      ListCoupon(
        model: _model,
        category: selectedIndexCategory,
        navigationForm: (dynamic model) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormContent(
                api: model['page'],
                model: model,
              ),
            ),
          );
        },
      ),
      SizedBox(height: 10),
    ];
  }

  _buildBanner() {
    // return CarouselBanner(model: _futureBanner, url: 'main/');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Carousel2(model: _futureBanner, url: 'privilege/'),
      ),
    );
  }

  void _onRefresh() async {
    _callRead();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() async {
    setState(
      () {
        _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
        _futureModelMyReward = postDio('${server}m/coupon/readMyReward', {
          "category": category,
          "limit": 10,
          "keySearch": keySearch,
          "status": "N"
        });

        // _futureModelMyLike = postDio('${server}m/coupon/readMyLike', {
        //   "category": category,
        //   "limit": 10,
        //   "keySearch": keySearch,
        // });

        _futureModelUsed = postDio('${server}m/coupon/readMyReward', {
          "category": category,
          "limit": 10,
          "keySearch": keySearch,
          "status": "A"
        });

        _futureModelExpired = postDio('${server}m/coupon/readMyReward', {
          "category": category,
          "limit": 10,
          "keySearch": keySearch,
          "status": "Z"
        });

        _futureCategory = postDioCategory(
          '${couponCategoryApi}read',
          {
            'skip': 0,
            'limit': 100,
          },
        );
      },
    );
  }
}
