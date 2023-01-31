import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/pages/profile/following_list.dart';
import 'package:wereward/pages/sell/add_product_sell.dart';
import 'package:wereward/pages/sell/list_sell_product.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class SellPage extends StatefulWidget {
  const SellPage({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final storage = new FlutterSecureStorage();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  dynamic tempData = {};
  Future<dynamic> _futureModel;
  String profileImageUrl = '';
  String profileFirstName = '';
  String profileLastName = '';
  int follower = 0;
  int following = 0;

  @override
  void initState() {
    profileImageUrl = widget.model['profileImageUrl'];
    profileFirstName = widget.model['profileFirstName'];
    profileLastName = widget.model['profileLastName'];
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
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 10),
            Expanded(child: _buildSmartRefresher(_buildBody())),
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        bottom: 10,
        top: MediaQuery.of(context).padding.top,
      ),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.all(profileImageUrl != '' ? 0.0 : 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Hero(
                      tag: 'profileImage',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: loadingImageNetwork(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          isProfile: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profileFirstName + ' ' + profileLastName,
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'ผู้ติดตาม ' + follower.toString(),
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(width: 1, height: 10, color: Colors.grey),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                fadeNav(FollowingList()),
                              ).then((value) => _callRead()),
                              child: Text(
                                'กำลังติดตาม ' + following.toString(),
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBody() {
    return ListView(
      children: [
        SizedBox(height: 5),
        FutureBuilder(
          future: _futureModel,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container();
            } else {
              return Container();
            }
          },
        ),
        Container(
          child: Text(''),
        ),
        _buildItemBtn(
          title: 'สินค้าของฉัน',
          icon: Icon(
            Icons.archive_outlined,
            color: Colors.red,
          ),
          onTap: () => Navigator.push(
            context,
            scaleTransitionNav(
              ListSellProduct(),
            ),
          ),
        ),
        _buildLine(),
        _buildItemBtn(
          title: 'เพิ่มสินค้า',
          icon: Icon(
            Icons.add_circle_outline,
            color: Colors.red,
          ),
          onTap: () => Navigator.push(
            context,
            scaleTransitionNav(
              AddProductSell(),
            ),
          ).then((value) => {if (value) toastFail(context, text: 'สำเร็จ')}),
        ),
      ],
    );
  }

  _buildLine() {
    return Container(
      height: 1,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.withOpacity(0.3),
    );
  }

  StackTap _buildItemBtn({String title, Icon icon, Function onTap}) {
    return StackTap(
      onTap: () => onTap(),
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        color: Colors.white,
        child: Row(
          children: [
            icon,
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 15),
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

  void _onRefresh() async {
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() async {
    profileImageUrl = await storage.read(key: 'profileImageUrl');
    profileFirstName = await storage.read(key: 'profileFirstName');
    profileLastName = await storage.read(key: 'profileLastName');

    _futureModel = postDio(server + 'm/', {});

    var followData = await postDio(server + 'm/follow/amount/read', {});

    setState(() {
      follower = followData['follower'];
      following = followData['following'];
    });
  }
}
