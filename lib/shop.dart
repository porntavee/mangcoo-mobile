import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/chat.dart';
import 'package:wereward/component/key_search.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/login.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/shop_item_list.dart';
import 'package:wereward/shop_report.dart';
import 'package:wereward/widget/ink_well_unfocus.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/product_card.dart';
import 'package:wereward/widget/stack_tap.dart';

import 'shared/api_provider.dart';

class ShopPage extends StatefulWidget {
  ShopPage({Key key, this.code, this.model}) : super(key: key);

  final String code;
  final dynamic model;

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with AutomaticKeepAliveClientMixin<ShopPage> {
  Future<dynamic> _futureModel;
  Future<dynamic> futurePromotionNews;
  Future<dynamic> _futureCategoryList;
  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final storage = new FlutterSecureStorage();
  PageController pageController;

  bool shopBlock = false;
  String keySearch = '';
  String category = '';
  String profileCode = '';
  String referenceShopCode = '';
  var tempData = List<dynamic>();
  int _limit = 10;
  ScrollController _scrollController;
  String textFollow = 'ติดตาม';
  int follower = 0;
  int currentPageValue = 0;
  dynamic tempCategory = [
    {'code': '0', 'title': 'ร้านค้า'},
    // {'code': '1', 'title': 'รายการสินค้า'},
    // {'code': '2', 'title': 'มาใหม่'},
    {'code': '1', 'title': 'หมวดหมู่'},
    // {'code': '4', 'title': 'โพสต์'},
  ];
  @override
  void initState() {
    pageController = PageController(initialPage: 0, keepPage: true);
    _callRead();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        body: InkWellUnfocus(child: _buildBody()),
      ),
    );
  }

  _buildBody() {
    return Stack(
      children: [
        _buildSliver(),
        _buildSearchBar(),
      ],
    );
  }

  _buildSliver() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) =>
          [_buildSliverAppBar()],
      body: PageView(
        controller: pageController,
        onPageChanged: (int page) {
          setState(() {
            currentPageValue = page;
          });
        },
        // physics: new NeverScrollableScrollPhysics(),
        children: [
          _buildSmartRefresher(_buildSliverList()),
          _buildSmartRefresher(_buildCategoryList()),
        ],
      ),
    );
  }

  Stack _buildBackgroudSliver() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: Image(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/background_home.png'),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.blueGrey.withOpacity(0.6),
              ),
            )
          ],
        ),
        Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 60),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: ClipOval(
                    child: Image.network(
                      widget.model['imageUrl'],
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Text(
                          '${widget.model['title']} >',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (referenceShopCode != widget.model['code'])
                  Column(
                    children: [
                      _buildBtnBorder(
                        textFollow,
                        () async => updateFollow(),
                      ),
                      SizedBox(height: 10),
                      _buildBtnBorder(
                        'พูดคุย',
                        () {
                          if (shopBlock == false)
                            Navigator.push(
                              context,
                              scaleTransitionNav(
                                ChatPage(
                                  referenceShopCode: widget.model['code'],
                                  profileCode: profileCode,
                                  isProfileSend: true,
                                  callByProfile: true,
                                ),
                              ),
                            );
                        },
                      )
                    ],
                  ),
                SizedBox(width: 10)
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  _buildBtnAboutShop(
                    'เรตติ้งร้าน',
                    '4.8 /50',
                    () {},
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white,
                  ),
                  _buildBtnAboutShop(
                    'ผู้ติดตาม',
                    follower.toString(),
                    () {},
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white,
                  ),
                  _buildBtnAboutShop(
                    'ประสิทธิภาพการแชท',
                    '90%',
                    () {},
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  // รายการ category
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      bottom: PreferredSize(
        child: Container(
          height: 50,
          width: double.infinity,
          color: Colors.white,
          child: ListView.builder(
            itemCount: tempCategory.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, __) => StackTap(
              onTap: () => setState(() {
                currentPageValue = __;
                pageController.jumpToPage(currentPageValue);
              }),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: __ == currentPageValue
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tempCategory[__]['title'],
                  style: TextStyle(
                    color: __ == currentPageValue
                        ? Theme.of(context).primaryColor
                        : Colors.black,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
            ),
          ),
        ),
        // child: CategorySelector5(
        //   model: tempCategory,
        //   onChange: (value) => {
        //     currentPageValue = int.parse(value),
        //     pageController.jumpToPage(currentPageValue),
        //   },
        // ),
        preferredSize: Size(0, 20),
      ),
      pinned: true,
      toolbarHeight: 40,
      brightness: Brightness.light,
      collapsedHeight: 70,
      expandedHeight: 250,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(bottom: 0),
        background: _buildBackgroudSliver(),
      ),
    );
  }

  Container _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 40),
              Expanded(
                  child: KeySearch(
                hint: 'ค้นหาในร้านค้า',
              )),
              SizedBox(width: 10),
              InkWell(
                onTap: () => _buildDialogReport(),
                child: Icon(
                  Icons.more_vert,
                  size: 25,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  ListView _buildSliverList() {
    return ListView(
      children: [
        ..._buildListProduct('สินค้าแนะนำสำหรับคุณ', _futureModel),
        SizedBox(height: 8),
        _buildGridProduct('ยอดขายสูงสุด', _futureModel),
        SizedBox(height: 8),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          margin: EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'สินค้าทั้งหมด',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'ดูทั้งหมด >',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<dynamic>(
          future: _futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                itemCount: snapshot.data.length,
                padding: EdgeInsets.only(left: 10),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                        color: Colors.white,
                      ),
                      child: ProductCard(
                        model: snapshot.data[index],
                        width: (MediaQuery.of(context).size.width / 2) - 17,
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Container();
            } else {
              return Center(
                child: Text('Loading...'),
              );
            }
          },
        ),
        SizedBox(height: 10 + MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  List<Widget> _buildListProduct(String title, Future<dynamic> future) {
    return <Widget>[
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'ดูทั้งหมด >',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
      Container(
        height: 165.0 + 130,
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 8),
        child: FutureBuilder<dynamic>(
          future: future,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) return Container();
              return ListView.builder(
                padding: EdgeInsets.only(left: 10),
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Container(
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          color: Colors.white,
                        ),
                        child: ProductCard(
                            model: snapshot.data[index], width: 158),
                      ),
                      SizedBox(width: 10),
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return DataError(onTap: () => _onRefresh());
            } else {
              return Center(
                child: Text('Loading...'),
              );
            }
          },
        ),
      ),
    ];
  }

  Widget _buildGridProduct(String title, Future<dynamic> future) {
    return FutureBuilder<dynamic>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) return Container();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  constraints: BoxConstraints(minHeight: 200),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.length,
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.58,
                      // childAspectRatio: MediaQuery.of(context).size.width /
                      //     (MediaQuery.of(context).size.height /
                      //         ((MediaQuery.of(context).size.width / 2) - 17) /
                      //         100),
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          color: Colors.white,
                        ),
                        child: ProductCard(
                          model: snapshot.data[index],
                          width: (MediaQuery.of(context).size.width / 2) - 17.5,
                        ),
                      );
                    },
                  ),
                ),
              ]);
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildCategoryList() {
    return FutureBuilder(
        future: _futureCategoryList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              padding: EdgeInsets.only(top: 1),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (_, __) => StackTap(
                onTap: () => Navigator.push(
                    context,
                    fadeNav(ShopItemListPage(
                      model: snapshot.data[__],
                      referenceShopCode: widget.model['code'],
                    ))),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        snapshot.data[__]['title'],
                        style: TextStyle(
                          fontFamily: 'Kaint',
                          fontSize: 15,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      )
                    ],
                  ),
                ),
              ),
              separatorBuilder: (_, __) => Container(
                height: 1,
                width: double.infinity,
                color: Color(0xFFe5e5e5),
              ),
              itemCount: snapshot.data.length,
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        });
  }

  Expanded _buildBtnAboutShop(String title, String value, Function press) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          press();
        },
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            )
          ],
        ),
      ),
    );
  }

  Stack _buildBtnBorder(String title, Function press) {
    return Stack(
      children: [
        Container(
          height: 35,
          width: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white),
            borderRadius: BorderRadius.circular(3),
            color: Colors.transparent,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(3),
            onTap: () {
              press();
            },
          ),
        ))
      ],
    );
  }

  _buildDialogReport() async {
    return await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        return SafeArea(
          child: CustomAlertDialog(
            height: 173,
            contentPadding: EdgeInsets.all(10),
            content: new Column(
              children: [
                _buildItemDialogReport(title: 'แชร์'),
                _buildItemDialogReport(
                  title: 'กลับไปหน้าหลัก',
                  icon: Icons.home_outlined,
                  onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeMartPage()),
                      (route) => false),
                ),
                _buildItemDialogReport(
                  title: 'รายงานผู้ใช้',
                  icon: Icons.assistant_photo_outlined,
                  onTap: () => Navigator.push(
                    context,
                    fadeNav(
                      ShopReport(code: widget.model['code']),
                    ),
                  ),
                ),
                _buildItemDialogReport(
                  title: shopBlock ? 'ปลดระงับผู้ใช้' : 'ระงับผู้ใช้',
                  icon: Icons.block_outlined,
                  onTap: () => {Navigator.pop(context), _buildBlockUser()},
                ),
                _buildItemDialogReport(
                  title: 'ต้องการความช่วยเหลือ',
                  line: false,
                  icon: Icons.contact_support_outlined,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildItemDialogReport({
    IconData icon = Icons.share_outlined,
    String title = '',
    Function onTap,
    bool line = true,
  }) {
    return StackTap(
      onTap: () => onTap(),
      child: Container(
        height: 30,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (line)
                    Container(
                      height: 0.5,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildBlockUser() async {
    return await showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        return SafeArea(
          child: CustomAlertDialog(
            height: 196,
            width: MediaQuery.of(context).size.width - 40,
            alignment: Alignment.center,
            contentPadding: EdgeInsets.only(top: 20),
            content: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'ระงับผู้ใช้ ${widget.model['title']} ?',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '${widget.model['title']} จะไม่สามารถพูกคุยกับคุณได้',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'คุณต้องการที่จะระงับการใช้งาน ${widget.model['title']}?',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(child: SizedBox(height: 20)),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey,
                ),
                Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: StackTap(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                          ),
                          onTap: () => Navigator.pop(context),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'ยกเลิก',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: StackTap(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(5),
                          ),
                          onTap: () => _block(),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              shopBlock ? 'ปลดระงับผู้ใช้' : 'ระงับผู้ใช้',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
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

  void _onRefresh() async {
    setState(() {
      _limit = 10;
    });
    _callRead();

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
    profileCode = await storage.read(key: 'profileCode10');

    setState(() {
      _futureModel = postDio('${server}m/shop/goods/read',
          {"referenceShopCode": widget.model['code']});
      _futureCategoryList = postDio(
          '${server}m/shop/category/read', {'code': widget.model['code']});
      shopBlock = widget.model['block'];
    });

    getFollower();

    if (profileCode != '') {
      getFollow();
    }
  }

  getFollower() async {
    var response = await postDio(
        server + 'm/follow/follower/read', {'reference': widget.model['code']});
    setState(() => follower = response.length);
  }

  getFollow() async {
    if (profileCode != '' && profileCode != null) {
      var response = await postDio(
          server + 'm/follow/single/read', {'reference': widget.model['code']});
      setState(
          () => textFollow = response[0]['isActive'] ? 'เลิกติดตาม' : 'ติดตาม');
      getFollower();
    } else {
      return;
    }
  }

  updateFollow() async {
    if (profileCode != '' && profileCode != null) {
      await postDio(
          server + 'm/follow/create', {'reference': widget.model['code']}).then(
        (value) => setState(
          () => textFollow = value['isActive'] ? 'เลิกติดตาม' : 'ติดตาม',
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(),
        ),
      );
    }
  }

  _block() async {
    setState(() {
      shopBlock = !shopBlock;
    });
    await postDio(server + 'm/shopBlock/update',
        {'referenceShopCode': widget.model['code'], 'isActive': shopBlock});

    Navigator.pop(context);
  }
}
