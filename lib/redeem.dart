import 'dart:async';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/component/material/form_content.dart';
import 'package:wereward/component/menu/list_content.dart';
import 'package:wereward/dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RedeemPage extends StatefulWidget {
  @override
  _RedeemPageState createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  Future<dynamic> _futureModel;
  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategory;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  var tempData = List<dynamic>();

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
      backgroundColor: Theme.of(context).backgroundColor,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            _buildHead(),
            Expanded(child: _buildSmartRefresher(_screen())),
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
                      'Redeem',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _screen() {
    return ListView(
      children: [
        SizedBox(height: 10),
        ListRedeem(
          model: _futureModel,
          navigationForm: (dynamic model) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormContent(
                  api: model['page'],
                  model: {'code': model['reference']},
                  readOnly: true,
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
        child: Carousel2(model: _futureBanner, url: 'privilege/'),
      ),
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
    _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
    _futureModel =
        postDioWithOutProfileCode('${server}m/redeem/read', {"status": "A"});

    for (var i = 0; i < 10; i++) {
      tempData.add({'title': '', 'imageUrl': '', 'description': ''});
    }
  }
}
