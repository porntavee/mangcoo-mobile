import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/material/form_content.dart';
import 'package:wereward/component/menu/list_content.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PromotionPage extends StatefulWidget {
  PromotionPage({Key key, this.checkShowBack}) : super(key: key);
  final bool checkShowBack;
  @override
  _PromotionPageState createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage>
    with AutomaticKeepAliveClientMixin<PromotionPage> {
  Future<dynamic> _futureModel;
  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategory;
  List<dynamic> categoryList;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int _limit = 10;
  int selectedIndexCategory = 0;
  var tempData = List<dynamic>();
  var subscriptionNetWork;
  var networkStatus;
  bool isSnackbarActive = false;

  @override
  void initState() {
    categoryList = [
      {'title': 'My Reward', 'value': '0'},
      {'title': 'My Like', 'value': '1'},
      {'title': 'Used', 'value': '2'},
      {'title': 'Expired', 'value': '3'}
    ];
    _callRead();
    super.initState();

    subscriptionNetWork = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkStatus = result;
      });
      // Got a new connectivity status!
    });
  }

// Be sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();

    subscriptionNetWork.cancel();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
              Container(
                alignment: Alignment.center,
                height: 40,
                child: Text(
                  'Promotion Feed',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              KeySearch(
                onKeySearchChange: (String val) {
                  setState(
                    () {
                      keySearch = val;
                    },
                  );
                  _onLoading();
                },
              ),
              SizedBox(height: 10),
              CategorySelector3(
                model: _futureCategory,
                onChange: (String val) {
                  setState(
                    () => {category = val},
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

  _buildList() {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return <Widget>[
      SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Carousel2(model: _futureBanner, url: 'promotion/'),
        ),
      ),
      SizedBox(height: 10),
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
      ListVertical(
        model: _futureModel,
        navigationForm: (dynamic model) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormContent(
                api: 'promotion',
                model: model,
              ),
            ),
          ).then((value) => _onLoading());
        },
        callBackRefresh: () {
          _callRead();
        },
      ),
      SizedBox(height: 10),
    ];
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
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() async {
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.none) {
    //   setState(() {
    //     isSnackbarActive = true;
    //   });
    //   // I am connected to a mobile network.
    //   // return showInSnackBar('No Internet');
    // } else if (connectivityResult == ConnectivityResult.mobile) {
    //   setState(() {
    //     isSnackbarActive = false;
    //   });
    //   Scaffold.of(context).hideCurrentSnackBar();
    //   // I am connected to a mobile network.
    // } else if (connectivityResult == ConnectivityResult.wifi) {
    //   setState(() {
    //     isSnackbarActive = false;
    //   });
    //   Scaffold.of(context).hideCurrentSnackBar();
    //   // I am connected to a wifi network.
    // }
    _futureBanner = postDio('${promotionBannerApi}read', {'limit': 10});
    _futureModel = postDio('${promotionApi}read',
        {"category": category, "limit": _limit, "keySearch": keySearch});

    _futureCategory = postDioCategory(
      '${promotionCategoryApi}read',
      {
        'skip': 0,
        'limit': 100,
      },
    );
  }

  void showInSnackBar(String value) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text(value),
        duration: Duration(hours: 1),
      ),
    );
  }
}
