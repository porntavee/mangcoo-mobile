import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/material/form_content.dart';
import 'package:wereward/component/menu/list_content.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final storage = new FlutterSecureStorage();
  Future<dynamic> _futureModel;
  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategory;
  dynamic _futurePoint = 0;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String profileCode = '';
  String keySearch = '';
  String category = '';
  int _limit = 10;
  var tempData = List<dynamic>();

  @override
  void initState() {
    _callRead();
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
                      'แลกสินค้า',
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
              CategorySelector3(
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
        _buildBanner(),
        SizedBox(height: 20),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 15),
          margin: EdgeInsets.only(bottom: 5),
          child: Text(
            'ใหม่ล่าสุด',
            style: TextStyle(
              color: themeChange.darkTheme
                  ? Colors.white
                  : Theme.of(context).primaryColor,
              fontSize: 13,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        ListVertical1(
          model: _futureModel,
          navigationForm: (dynamic model) {
            var isReward = false;
            if (model['point'] <= _futurePoint[0]['sumPoint'] ||
                (profileCode == null || profileCode == '')) {
              isReward = true;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormContent(
                  api: 'product',
                  model: model,
                  isReward: isReward,
                ),
              ),
            );
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

  _buildList(dynamic model) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: model.length,
      itemBuilder: (context, index) => _buildItem(model[index]),
    );
  }

  _buildItem(dynamic model) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      width: double.infinity,
      height: 90,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 0,
            blurRadius: 6,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Image.network(
            model['imageUrl'],
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              model['title'],
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                // color: themeChange.darkTheme ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  _buildBanner() {
    // return CarouselBanner(model: _futureBanner, url: 'main/');
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Carousel2(model: _futureBanner, url: 'm/Banner/product/'),
        ));
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
    _futureBanner = postDio(server + 'm/rotation/product/read', {'limit': 10});
    _futureModel = postDio('${server}m/product/read',
        {"category": category, "limit": _limit, "keySearch": keySearch});

    _futureCategory = postDioCategory(
      '${productCategoryApi}read',
      {
        'skip': 0,
        'limit': 100,
      },
    );

    profileCode = await storage.read(key: 'profileCode10');
    _futurePoint = await postDio(server + 'm/point/readCheckIn', {});

    for (var i = 0; i < 10; i++) {
      tempData.add({'title': '', 'imageUrl': ''});
    }
  }
}
