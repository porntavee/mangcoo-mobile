import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/build_shop_like.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/widget/header.dart';

class LikePage extends StatefulWidget {
  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  final storage = new FlutterSecureStorage();
  Future<dynamic> _futurePoi;
  Future<dynamic> _futureBanner;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  String profileImageUrl = '';
  String profileFirstName = '';
  String profileLastName = '';
  String profileCode = '';
  var tempData = List<dynamic>();
  Future<dynamic> _futureProfile;
  Future<dynamic> _futureVerify;
  Future<dynamic> _futureOrganizationImage;

  @override
  void initState() {
    _read();
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
        appBar: header2(context, title: 'สิ่งที่ฉันถูกใจ'),
        backgroundColor: Theme.of(context).backgroundColor,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _buildSmartRefresher(_screen()),
        ),
      ),
    );
  }

  _screen() {
    return ListView(
      children: [
        SizedBox(height: 10),
        BuildShopLike(
          model: _futurePoi,
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
    _read();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _read();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _read() async {
    profileImageUrl = await storage.read(key: 'profileImageUrl');
    profileFirstName = await storage.read(key: 'profileFirstName');
    profileLastName = await storage.read(key: 'profileLastName');

    if (profileFirstName == null) profileFirstName = '';
    if (profileLastName == null) profileLastName = '';
    if (profileImageUrl == null) profileImageUrl = '';

    //read profile
    profileCode = await storage.read(key: 'profileCode10');
    if (profileCode != '' && profileCode != null) {
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
        _futureOrganizationImage =
            postDio(organizationImageReadApi, {"code": profileCode});
        _futureVerify =
            postDio(organizationImageReadApi, {"code": profileCode});
      });
    }
    setState(() {
      _futurePoi = postDio(
          server + 'm/goods/read', {'profileCode': profileCode, "like": true});
    });
    setState(() {});
  }
}
