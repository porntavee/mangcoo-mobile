import 'dart:async';
import 'dart:convert';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';
import 'package:wereward/pages/main_popup/dialog_main_popup.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/nav_animation.dart';

import 'component/material/form_content_shop.dart';

class CategoryGoodsPage extends StatefulWidget {
  CategoryGoodsPage({Key key, this.category}) : super(key: key);

  final dynamic category;

  @override
  _CategoryGoodsPageState createState() => _CategoryGoodsPageState();
}

class _CategoryGoodsPageState extends State<CategoryGoodsPage> {
  final storage = new FlutterSecureStorage();

  Future<dynamic> _futureModel;
  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategory;
  Future<dynamic> _futureForceAds;
  List<dynamic> categoryList;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int _limit = 10;
  var tempData = List<dynamic>();
  int selectedIndexCategory = 0;

  @override
  void initState() {
    _callRead();
    categoryList = [
      {'title': 'ยอดนิยม', 'value': '0'},
      {'title': 'ล่าสุด', 'value': '1'},
      {'title': 'สินค้าขายดี', 'value': '2'},
      {'title': 'ราคา', 'value': '3'},
    ];
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
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              _buildHead(),
              SizedBox(height: 20),
              Expanded(child: _buildSmartRefresher(buildGrid())),
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
      padding:
          EdgeInsets.only(bottom: 10, top: MediaQuery.of(context).padding.top),
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              Row(
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
                  Expanded(
                    child: KeySearch(
                      hint: widget.category['title'],
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
              SizedBox(height: 15),
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              var status;
              setState(() {
                selectedIndexCategory = index;
                switch (index) {
                  case 1:
                    status = 'ยอดนิยม';
                    break;
                  case 2:
                    status = 'P';
                    break;
                  case 3:
                    status = 'A';
                    break;
                  case 4:
                    status = 'R';
                    break;
                  default:
                    status = '';
                }
                // _futureModel =
                //     postDio('${server}m/cart/order/read', {'status': status});
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
                    ? Theme.of(context).accentColor
                    : Color(0xFFFFFFFF),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 7.0,
              ),
              child: Text(
                model[index]['title'],
                style: TextStyle(
                  color: index == selectedIndexCategory
                      ? Color(0xFFFFFFFF)
                      : Theme.of(context).accentColor,
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
    setState(() {
      _futureModel = postDio(
          server + 'm/goods/read', {"lv1Shop": widget.category['code']});
      _futureForceAds = postDio('${forceAdsApi}read',
          {'skip': 0, 'limit': 10, 'privilegePage': true});
      _futureCategory = postDioCategory(
        '${privilegeCategoryApi}read',
        {
          'skip': 0,
          'limit': 100,
        },
      );
    });
  }

  buildGrid() {
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width / 2) - 20;
    return FutureBuilder<dynamic>(
      future: _futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return GridView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.64,
                // childAspectRatio: MediaQuery.of(context).size.width /
                //     (MediaQuery.of(context).size.height / 1.6),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    left: index % 2 != 0 ? 5 : 0,
                    right: index % 2 == 0 ? 5 : 0,
                  ),
                  child: buildCard(
                    model: snapshot.data[index],
                    index: index,
                    lastIndex: snapshot.data.length,
                    itemWidth: itemWidth,
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: 4,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  buildCard(
      {dynamic model, int index = 0, int lastIndex = 0, double itemWidth}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          scaleTransitionNav(
            FormContentShop(
              api: 'goods',
              model: model,
              urlRotation: rotationNewsApi,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                model['imageUrl'],
                width: itemWidth,
                height: itemWidth,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            child: Text(
                              model['price'] != null
                                  ? '${priceFormat.format(model['price'])}' +
                                      " บาท"
                                  : '',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 15,
                          width: 15,
                          child: Image.asset(
                            model['like']
                                ? 'assets/images/heart_full.png'
                                : 'assets/images/heart.png',
                            fit: BoxFit.contain,
                            color: model['like'] ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      constraints: BoxConstraints(minHeight: 35),
                      child: Text(
                        '${model['title']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Kanit',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
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
}
