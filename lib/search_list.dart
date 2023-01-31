import 'dart:async';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/material/form_content_shop.dart';
import 'package:wereward/component/menu/list_content.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/shop.dart';
import 'package:wereward/widget/nav_animation.dart';

class SearchListPage extends StatefulWidget {
  @override
  _SearchListPageState createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  Future<dynamic> futureShop;
  Future<dynamic> futurePoi;
  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
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
              Expanded(
                child: _buildSmartRefresher(
                  _screen(),
                ),
              ),
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
                      'Mart',
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 30,
                      // padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                  ),
                  // SizedBox(width: 10),
                  // Container(
                  //   child: InkWell(
                  //     onTap: () {
                  //       // _buildDialogDarkMode();
                  //     },
                  //     child: Container(
                  //       height: 20,
                  //       width: 20,
                  //       child: Icon(
                  //         Icons.format_line_spacing,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
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
      enablePullUp: false,
      header: WaterDropHeader(
        complete: Container(
          child: Text(''),
        ),
        completeDuration: Duration(milliseconds: 0),
      ),
      // shrinkWrap: true, // use it
      physics: ClampingScrollPhysics(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          return Container(
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

  _screen() {
    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'ร้านค้า ' + keySearch,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListContent4(
          model: futureShop,
          navigationForm: (dynamic model) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ShopPage(
                  model: model,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'ผลการค้นหา ' + keySearch + ' ในสินค้า',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListContent2(
            model: futurePoi,
            navigationForm: (dynamic model) {
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
          ),
        ),
      ],
    );
  }

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
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

  _callRead() {
    futurePoi = postDio('${server}m/goods/read', {
      "limit": 10,
      "keySearch": keySearch,
    });
    futureShop = postDio('${server}m/shop/read', {
      "limit": 10,
      "keySearch": keySearch,
    });

    for (var i = 0; i < 10; i++) {
      tempData.add({'title': '', 'imageUrl': ''});
    }
  }
}
