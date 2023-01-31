import 'dart:async';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/material/form_content.dart';
import 'package:wereward/component/menu/list_content.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShopOldPage extends StatefulWidget {
  ShopOldPage({Key key, this.code}) : super(key: key);

  final String code;
  @override
  _ShopOldPageState createState() => _ShopOldPageState();
}

class _ShopOldPageState extends State<ShopOldPage> {
  Future<dynamic> futureModel;
  Future<dynamic> futurePromotionNews;
  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  var tempData = List<dynamic>();
  int _limit = 10;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              _screen({'message': '', 'objectData': tempData}),
            )),
          ],
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
                      'Shop',
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

  _screen(dynamic model) {
    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        SizedBox(height: 10),
        if (keySearch != '')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'ผลการค้นหา ' + keySearch + ' ใน shop ',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
              ),
            ),
          ),
        SizedBox(height: 10),
        ListContent3(
          model: futureModel,
          navigationForm: (dynamic model) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormContent(
                  api: 'poi',
                  model: model,
                ),
              ),
            );
          },
        ),
      ],
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
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() {
    // print(widget.code);
    futureModel = postDio('${server}m/poi/read',
        {"limit": _limit, "category": widget.code, "keySearch": keySearch});

    for (var i = 0; i < 10; i++) {
      tempData.add({'title': '', 'imageUrl': ''});
    }
  }
}
