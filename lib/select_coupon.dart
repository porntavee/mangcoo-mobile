import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:wereward/manage_address_edit.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/widget/nav_animation.dart';

class SelectCouponPage extends StatefulWidget {
  @override
  _SelectCouponPageState createState() => _SelectCouponPageState();
}

class _SelectCouponPageState extends State<SelectCouponPage> {
  List<dynamic> model;
  Future<dynamic> _futureModel;
  PageController pageController;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  var tempData = List<dynamic>();
  int currentTabIndex = 0;

  @override
  void initState() {
    _callRead();
    pageController = new PageController(initialPage: currentTabIndex);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Expanded(
              child: PageView(
                controller: pageController,
                physics: new NeverScrollableScrollPhysics(),
                children: [
                  // tap 1
                  _buildSmartRefresher(buildFutureBuilder()),
                  // tap 2
                  _buildSmartRefresher(buildFutureBuilder()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
      future: _futureModel,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return buildListView(snapshot);
          } else {
            return Container(
              height: 150,
              child: Center(
                child: Text(
                  'ไม่พบคูปอง',
                  style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Container(
            height: 150,
            child: Center(
              child: InkWell(
                onTap: () => _onRefresh(),
                child: Text('เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง'),
              ),
            ),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
            itemCount: 4,
            itemBuilder: (context, index) {
              return LoadingTween(
                height: 150,
                width: double.infinity,
              );
            },
          );
        }
      },
    );
  }

  ListView buildListView(AsyncSnapshot snapshot) {
    return ListView.separated(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: snapshot.data.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildItem(snapshot.data[index]);
      },
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
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  SizedBox(width: 5),
                  Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      'รายการคูปอง',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButtonHeader('คูปองที่ใช้ได้ (3)', 0),
                  SizedBox(width: 10),
                  buildButtonHeader('คูปองที่ใช้ไม่ได้ (10)', 1)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InkWell buildButtonHeader(String title, int index) {
    return InkWell(
      onTap: () => {
        setState(() => currentTabIndex = index),
        pageController.jumpToPage(index),
      },
      child: Container(
        height: 30,
        width: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: currentTabIndex == index ? Colors.white : Colors.transparent,
          border: Border.all(
            width: 1,
            color: currentTabIndex == index
                ? Theme.of(context).accentColor
                : Colors.white,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: currentTabIndex == index
                ? Theme.of(context).accentColor
                : Colors.white,
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

  _buildItem(dynamic model) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Navigator.push(
        //   context,
        //   scaleTransitionNav(ManageAddressEditPage(code: model['code'])),
        // ).then(
        //   (value) => {if (value == 'success') _onLoading()},
        // );
      },
      child: Container(
        height: 150,
        width: double.infinity,
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'เมื่อซื้อสินค้าครบ 2,500\n',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                      children: const <TextSpan>[
                        TextSpan(
                          text: 'ลด',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' 100',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  if (currentTabIndex == 1)
                    Container(
                      height: 22,
                      width: 139,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        'สินค้าไม่ตรงกับเงื่อนไข',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  Text(
                    "ใช้ได้กับสินค้าประเภท ของใช้ในบ้าน อุปกรณ์ช่างและสวน และหนังสือที่เข้าร่วมรายการ",
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 11,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  Text(
                    '01/01/2021 - 31/06/2021',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 11,
                      color: Color(0xFF707070),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
    await _callRead();

    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    await _callRead();
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // _refreshController.refreshCompleted();
    // if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  _callRead() {
    for (var i = 0; i < 4; i++) {
      tempData.add({
        'name': '',
        'phone': '',
        'address': '',
        'province': '',
        'isDefault': i == 0 ? true : false
      });
    }
    setState(() {
      _futureModel = postDio('${server}m/coupon/read', {});
    });
  }
}
