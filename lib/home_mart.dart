import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:wereward/cart_list.dart';
import 'package:wereward/category_goods_page.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/coupon.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/history_page.dart';
import 'package:wereward/login.dart';
import 'package:wereward/manage_address.dart';
import 'package:wereward/notification_shop_list.dart';
import 'package:wereward/order_list.dart';
import 'package:wereward/pages/policy_v2.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/pages/profile/user_information.dart';
import 'package:wereward/promotion.dart';
import 'package:wereward/search_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/pages/notification/notification_list.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'component/build_shop.dart';
import 'pages/main_popup/dialog_main_popup.dart';
import 'shared/notification_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeMartPage extends StatefulWidget {
  HomeMartPage({Key key, this.pageIndex}) : super(key: key);
  final int pageIndex;
  @override
  _HomeMartPageState createState() => _HomeMartPageState();
}

class _HomeMartPageState extends State<HomeMartPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<HomeMartPage> {
  final storage = new FlutterSecureStorage();
  DateTime currentBackPressTime;
  // PageController pageController;

  Future<dynamic> _futureBanner;
  Future<dynamic> _futureMainPopUp;
  Future<dynamic> _futureModel;
  Future<dynamic> _futureMCategory;

  bool isDialog = false;
  bool clickArrow = false;
  bool networkConnected = false;

  String currentLocation = '-';
  String profileImageUrl = '';
  String profileFirstName = '';
  String profileLastName = '';
  String profileCode = '';
  String referenceShopCode = '';
  final seen = Set<String>();
  List unique = [];
  List imageLv0 = [];
  bool scBool = true;

  bool notShowOnDay = false;
  bool hiddenMainPopUp = false;
  bool checkDirection = false;
  LatLng latLng = LatLng(0, 0);
  int amountItemInCart = 0;
  int amountItemStatusW = 0;
  int _limit = 10;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  StreamSubscription<Map> _notificationSubscription;
  ScrollController _scrollController;
  int currentTabIndex = 0;

  String promotionCategory = '';
  List<TargetFocus> targets = List();
  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();
  GlobalKey keyButton6 = GlobalKey();
  GlobalKey keyButton7 = GlobalKey();
  GlobalKey keyButton8 = GlobalKey();
  GlobalKey keyButton9 = GlobalKey();
  GlobalKey keyButton10 = GlobalKey();
  GlobalKey keyButton11 = GlobalKey();
  int pageIndex = 0;

  @override
  void initState() {
    _read();
    _scrollController = ScrollController();

    super.initState();
    // NotificationService.instance.start();
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  void dispose() {
    // _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final themeChange = Provider.of<DarkThemeProvider>(context);
    // _callReadPolicy();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
            child: PageView(
              controller: pageController,
              physics: new NeverScrollableScrollPhysics(),
              children: [
                // tap 1
                Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    children: [
                      _buildHeadMain(),
                      Expanded(
                        child: _buildSmartRefresher(
                          ListView(
                            children: _buildListMenuMain(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // tap 2
                PromotionPage(),
                //tap 3
                CouponPage(),
                // tap 4
                profileCode != null && profileCode != ''
                    ? UserInformationPage()
                    : LoginPage(),
              ],
            ),
            onWillPop: _callConfirmExit),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  _buildBottomNavBar() {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      padding: EdgeInsets.only(top: 10),
      height: 55 + MediaQuery.of(context).padding.bottom,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        // borderRadius: BorderRadius.vertical(
        //   top: Radius.circular(15),
        // ),
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
          _buildTap(0, 'หน้าแรก', 'assets/images/home.png', key: keyButton7),
          _buildTap(1, 'คูปอง', 'assets/images/privilege.png', key: keyButton8),
          _buildTap(2, 'คูปองของฉัน', 'assets/images/coupon.png',
              key: keyButton9),
          profileCode != '' && profileCode != null
              ? _buildTap(
                  3,
                  'บัญชี',
                  profileImageUrl,
                  key: keyButton10,
                  isNetwork: true,
                )
              : _buildTap(3, 'เข้าสู่ระบบ', 'assets/images/account.png',
                  key: keyButton10)
        ],
      ),
    );
  }

  _buildTap(
    int index,
    String title,
    String pathImage, {
    bool isNetwork = false,
    Key key,
    Function onTap,
  }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    Color color = currentTabIndex == index ? Colors.white : Colors.white70;
    return Flexible(
      key: key,
      flex: 1,
      child: new Center(
        child: new Container(
          child: new Material(
            color: Colors.transparent,
            child: new InkWell(
              radius: 60,
              // borderRadius: BorderRadius.circular(26),
              splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
              onTap: () {
                setState(() {
                  currentTabIndex = index;
                  pageController.jumpToPage(index);
                  // pageController.animateToPage(index,
                  //     duration: Duration(milliseconds: 10),
                  //     curve: Curves.fastOutSlowIn);
                });
              },
              child: new Container(
                width: double.infinity,
                height: double.infinity,
                // padding: EdgeInsets.only(
                //   top: 5,
                // ),
                child: Column(
                  children: [
                    isNetwork
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: loadingImageNetwork(
                              pathImage,
                              height: 25,
                              width: 25,
                              isProfile: true,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            pathImage,
                            height: 25,
                            width: 25,
                            color: color,
                          ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'SFThonburi',
                          fontSize: 11,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("เกิดข้อผิดพลาด");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("");
          } else {
            body = Text("ไม่พบข้อมูลเพิ่มเติม");
          }
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

  _buildHeadMain() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: InkWell(
                      key: keyButton1,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchListPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 25,
                              color: Colors.transparent,
                              child: Image.asset(
                                'assets/images/search.png',
                                height: 20.0,
                                width: 20.0,
                                color: Color(0xFF707070),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Mangcoo',
                              style: TextStyle(
                                fontFamily: 'SFThonburi',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          if (profileCode != '' && profileCode != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartListPage(),
                              ),
                            ).then((value) => getCountItemInCart());
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => LoginPage(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          child: Image.asset(
                            'assets/images/shopping-cart.png',
                            height: 30,
                            width: 30,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 15,
                          width: 15,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            amountItemInCart.toString(),
                            style: TextStyle(
                              fontFamily: 'SFThonburi',
                              fontSize: 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (referenceShopCode != '' && referenceShopCode != null)
                    SizedBox(width: 10),
                  if (referenceShopCode != '' && referenceShopCode != null)
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            if (profileCode != '' && profileCode != null) {
                              Navigator.push(
                                context,
                                scaleTransitionNav(NotificationShopListPage()),
                              ).then((value) => getCountOrder());
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginPage(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              amountItemStatusW.toString(),
                              style: TextStyle(
                                fontFamily: 'SFThonburi',
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildListMenuMain() {
    return <Widget>[
      CarouselBanner(model: _futureBanner, url: 'main/', height: 150),
      SizedBox(height: 20),
      Container(
        height: 100,
        child: _buildListButtonMainMenu(),
      ),
      // Column(
      //   children: [
      //     _buildListButtonMainMenu(),
      //   ],
      // ),
      // SizedBox(height: 20),
      // _buildListButtonCategory(),
      SizedBox(height: 10),
      // BuildShop(
      //   title: "มาแรง",
      //   model: _futureSpecialOffer,
      // ),
      // SizedBox(height: 10),
      // _buildRotation(),
      SizedBox(height: 10),
      BuildShop(
        title: tr('dailyRecommendedProducts'),
        model: _futureModel,
      ),
      SizedBox(
        height: 10,
      )
    ];
  }

  _buildListButtonMainMenu() {
    return CupertinoScrollbar(
      isAlwaysShown: true,
      thickness: 1,
      thicknessWhileDragging: 5,
      controller: _scrollController,
      child: ListView(
        shrinkWrap: true, // 1st add
        physics: ClampingScrollPhysics(), // 2nd
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        children: [
          SizedBox(
            width: 80,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.grey, // inkwell color
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/images/cactus.png',
                          color: Colors.white,
                        ),

                        // Icon(
                        //   Icons.shopping_bag_outlined,
                        //   size: 35,
                        //   color: Colors.white,
                        // ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryGoodsPage(
                              category: {
                                'title': 'กระบองเพชร',
                                'code': '20211007103524-123-139'
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'กระบองเพชร',
                  style: TextStyle(
                    fontFamily: 'SFThonburi',
                    fontSize: 12,
                    // color: Theme.of(context).accentColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.grey, // inkwell color
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/images/paper-bags.png',
                          color: Colors.white,
                        ),

                        // Icon(
                        //   Icons.shopping_bag_outlined,
                        //   size: 35,
                        //   color: Colors.white,
                        // ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryGoodsPage(
                              category: {
                                'title': 'กระเป๋า',
                                'code': '20211008144321-458-695'
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'กระเป๋า',
                  style: TextStyle(
                    fontFamily: 'SFThonburi',
                    fontSize: 12,
                    // color: Theme.of(context).accentColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // SizedBox(
          //   width: 80,
          //   child: Column(
          //     children: [
          //       ClipRRect(
          //         borderRadius: BorderRadius.all(
          //           Radius.circular(15.0),
          //         ),
          //         child: Material(
          //           color: Theme.of(context).primaryColor, // button color
          //           child: InkWell(
          //             splashColor: Colors.grey, // inkwell color
          //             child: Container(
          //               padding: EdgeInsets.all(10),
          //               width: 50,
          //               height: 50,
          //               child: Image.asset(
          //                 'assets/images/shop.png',
          //                 color: Colors.white,
          //               ),

          //               // SizedBox(
          //               //   width: 50,
          //               //   height: 50,
          //               //   child: Icon(
          //               //     Icons.shopping_bag_outlined,
          //               //     size: 35,
          //               //     color: Colors.white,
          //               //   ),
          //             ),
          //             onTap: () {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => ShopListPage(),
          //                 ),
          //               );
          //             },
          //           ),
          //         ),
          //       ),
          //       SizedBox(
          //         height: 10,
          //       ),
          //       Text(
          //         'ร้านค้า',
          //         style: TextStyle(
          //           fontFamily: 'SFThonburi',
          //           fontSize: 12,
          //           // color: Theme.of(context).accentColor,
          //         ),
          //         textAlign: TextAlign.center,
          //         maxLines: 1,
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.grey, // inkwell color
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/images/operation.png',
                          color: Colors.white,
                        ),

                        // SizedBox(
                        //   width: 50,
                        //   height: 50,
                        //   child: Icon(
                        //     Icons.history,
                        //     size: 35,
                        //     color: Colors.white,
                        //   ),
                      ),
                      onTap: () {
                        if (profileCode != '' && profileCode != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => HistoryPage(),
                              // builder: (BuildContext context) => MyCreditCardPage(),
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
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'การชำระเงิน',
                  style: TextStyle(
                    fontFamily: 'SFThonburi',
                    fontSize: 12,
                    // color: Theme.of(context).accentColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.grey, // inkwell color
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/images/home-address.png',
                          color: Colors.white,
                        ),

                        // SizedBox(
                        //   width: 50,
                        //   height: 50,
                        //   child: Icon(
                        //     Icons.home,
                        //     size: 35,
                        //     color: Colors.white,
                        //   ),
                      ),
                      onTap: () {
                        if (profileCode != '' && profileCode != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ManageAddressPage(),
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
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'จัดการที่อยู่',
                  style: TextStyle(
                    fontFamily: 'SFThonburi',
                    fontSize: 12,
                    // color: Theme.of(context).accentColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                  child: Material(
                    color: Theme.of(context).primaryColor, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/images/history.png',
                          color: Colors.white,
                        ),

                        // SizedBox(
                        //   width: 50,
                        //   height: 50,
                        //   child: Icon(
                        //     Icons.list_alt,
                        //     size: 35,
                        //     color: Colors.white,
                        //   ),
                      ),
                      onTap: () {
                        if (profileCode != '' && profileCode != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  OrderListPage(),
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
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'รายการสั่งซื้อ',
                  style: TextStyle(
                    fontFamily: 'SFThonburi',
                    fontSize: 12,
                    // color: Theme.of(context).accentColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    onSetPage() {
      // _buildTap(1, 'Promotion', 'assets/images/tag.png', key: keyButton8);
      // setState(() {
      //   currentTabIndex = 1;
      //   pageController.jumpToPage(1);
      //   // pageController.animateToPage(index,
      //   //     duration: Duration(milliseconds: 10),
      //   //     curve: Curves.fastOutSlowIn);
      // });
      setState(() {
        pageIndex = widget.pageIndex != null ? widget.pageIndex : 0;
        currentTabIndex = pageIndex != 0 ? pageIndex : currentTabIndex;
      });
    }
    // return Row(
    //   children: [
    //     Expanded(
    //       child: Column(
    //         children: [
    //           ClipRRect(
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(15.0),
    //             ),
    //             child: Material(
    //               color: Theme.of(context).primaryColor, // button color
    //               child: InkWell(
    //                 splashColor: Colors.grey, // inkwell color
    //                 child: SizedBox(
    //                   width: 50,
    //                   height: 50,
    //                   child: Icon(
    //                     Icons.shopping_bag_outlined,
    //                     size: 35,
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //                 onTap: () {
    //                   Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                       builder: (context) => ShopListPage(),
    //                     ),
    //                   );
    //                 },
    //               ),
    //             ),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Text(
    //             'ร้านค้า',
    //             style: TextStyle(
    //               fontFamily: 'SFThonburi',
    //               fontSize: 11,
    //               // color: Theme.of(context).accentColor,
    //             ),
    //             textAlign: TextAlign.center,
    //             maxLines: 1,
    //           ),
    //         ],
    //       ),
    //     ),
    //     Expanded(
    //       child: Column(
    //         children: [
    //           ClipRRect(
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(15.0),
    //             ),
    //             child: Material(
    //               color: Theme.of(context).primaryColor, // button color
    //               child: InkWell(
    //                 splashColor: Colors.grey, // inkwell color
    //                 child: SizedBox(
    //                   width: 50,
    //                   height: 50,
    //                   child: Icon(
    //                     Icons.history,
    //                     size: 35,
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //                 onTap: () {
    //                   if (profileCode != '' && profileCode != null) {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (BuildContext context) => HistoryPage(),
    //                         // builder: (BuildContext context) => MyCreditCardPage(),
    //                       ),
    //                     );
    //                   } else {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (BuildContext context) => LoginPage(),
    //                       ),
    //                     );
    //                   }
    //                 },
    //               ),
    //             ),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Text(
    //             'การชำระเงิน',
    //             style: TextStyle(
    //               fontFamily: 'SFThonburi',
    //               fontSize: 11,
    //               // color: Theme.of(context).accentColor,
    //             ),
    //             textAlign: TextAlign.center,
    //             maxLines: 1,
    //           ),
    //         ],
    //       ),
    //     ),
    //     Expanded(
    //       child: Column(
    //         children: [
    //           ClipRRect(
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(15.0),
    //             ),
    //             child: Material(
    //               color: Theme.of(context).primaryColor, // button color
    //               child: InkWell(
    //                 splashColor: Colors.grey, // inkwell color
    //                 child: SizedBox(
    //                   width: 50,
    //                   height: 50,
    //                   child: Icon(
    //                     Icons.home,
    //                     size: 35,
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //                 onTap: () {
    //                   if (profileCode != '' && profileCode != null) {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (BuildContext context) =>
    //                             ManageAddressPage(),
    //                       ),
    //                     );
    //                   } else {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (BuildContext context) => LoginPage(),
    //                       ),
    //                     );
    //                   }
    //                 },
    //               ),
    //             ),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Text(
    //             'จัดการที่อยู่',
    //             style: TextStyle(
    //               fontFamily: 'SFThonburi',
    //               fontSize: 11,
    //               // color: Theme.of(context).accentColor,
    //             ),
    //             textAlign: TextAlign.center,
    //             maxLines: 1,
    //           ),
    //         ],
    //       ),
    //     ),
    //     Expanded(
    //       child: Column(
    //         children: [
    //           ClipRRect(
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(15.0),
    //             ),
    //             child: Material(
    //               color: Theme.of(context).primaryColor, // button color
    //               child: InkWell(
    //                 splashColor: Colors.red, // inkwell color
    //                 child: SizedBox(
    //                   width: 50,
    //                   height: 50,
    //                   child: Icon(
    //                     Icons.list_alt,
    //                     size: 35,
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //                 onTap: () {
    //                   if (profileCode != '' && profileCode != null) {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (BuildContext context) => OrderListPage(),
    //                       ),
    //                     );
    //                   } else {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (BuildContext context) => LoginPage(),
    //                       ),
    //                     );
    //                   }
    //                 },
    //               ),
    //             ),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Text(
    //             'รายการสั่งซื้อ',
    //             style: TextStyle(
    //               fontFamily: 'SFThonburi',
    //               fontSize: 11,
    //               // color: Theme.of(context).accentColor,
    //             ),
    //             textAlign: TextAlign.center,
    //             maxLines: 1,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  _buildListButtonCategory() {
    final listRow = new List<Widget>();
    final listRow2 = new List<Widget>();
    var count = 0;

    return FutureBuilder<dynamic>(
      future: _futureMCategory,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          for (var i = 0; i < snapshot.data.length; i++) {
            if (count < 2) {
              listRow.add(
                _buidItemGrid(
                  title: snapshot.data[i]['title'],
                  image: snapshot.data[i]['imageUrl'],
                  isImageNetwork: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryGoodsPage(
                          category: snapshot.data[i],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            count++;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 15),
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "หมวดหมู่",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'SFThonburi',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: listRow,
              ),
              Row(
                children: listRow2,
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container(height: 170);
        }
      },
    );

    // return FutureBuilder<dynamic>(
    //   future: _futureMCategory,
    //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //     if (snapshot.hasData) {
    //       for (var i = 0; i < snapshot.data.length; i++) {
    //         if (count < 4) {
    //           listRow.add(
    //             _buidItemGrid(
    //               title: snapshot.data[i]['title'],
    //               image: snapshot.data[i]['imageUrl'],
    //               isImageNetwork: true,
    //               onTap: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => CategoryGoodsPage(
    //                       category: snapshot.data[i],
    //                     ),
    //                   ),
    //                 );
    //               },
    //             ),
    //           );
    //         } else if (count >= 4 && count < 8) {
    //           listRow2.add(
    //             _buidItemGrid(
    //               title: snapshot.data[i]['title'],
    //               image: snapshot.data[i]['imageUrl'],
    //               isImageNetwork: true,
    //               onTap: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => CategoryGoodsPage(
    //                       category: snapshot.data[i],
    //                     ),
    //                   ),
    //                 );
    //               },
    //             ),
    //           );
    //         }
    //         count++;
    //       }

    //       return Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Row(
    //             children: [
    //               Expanded(
    //                 flex: 1,
    //                 child: Container(
    //                   alignment: Alignment.centerLeft,
    //                   padding: EdgeInsets.only(left: 15),
    //                   margin: EdgeInsets.only(bottom: 5),
    //                   child: Text(
    //                     "หมวดหมู่",
    //                     style: TextStyle(
    //                       color: Color(0xFF000000),
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 15,
    //                       fontFamily: 'SFThonburi',
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           SizedBox(height: 10),
    //           Row(
    //             children: listRow,
    //           ),
    //           Row(
    //             children: listRow2,
    //           ),
    //         ],
    //       );
    //     } else if (snapshot.hasError) {
    //       return Container();
    //     } else {
    //       return Container(height: 170);
    //     }
    //   },
    // );
  }

  _buidItemGrid(
      {Key key,
      String title,
      String image,
      Function onTap,
      bool isImageNetwork = false}) {
    return Expanded(
      key: key,
      flex: 1,
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
          height: 170,
          child: Column(
            children: [
              Container(
                // color: Colors.black,
                // height: 50,
                // width: 50,
                child: isImageNetwork
                    ? loadingImageNetwork(
                        image,
                        height: 150,
                        width: 150,
                      )
                    : Image.asset(
                        image,
                        // height: 30,
                        // width: 30,
                        // color: Theme.of(context).primaryColor,
                      ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'SFThonburi',
                      fontSize: 12,
                      // color: Theme.of(context).accentColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildRotation() {
    // return CarouselBanner(model: _futureBanner, url: 'main/');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CarouselBanner(model: _getRotation(), url: 'main/'),
      ),
    );
  }

  Future<Null> _callReadPolicy() async {
    var policy = await postDio(server + "m/policy/read",
        {"category": "application", "skip": 0, "limit": 10});

    if (policy.length > 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => PolicyV2Page(
            category: 'application',
            navTo: () {
              // Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HomeMartPage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  _read() async {
    profileImageUrl = await storage.read(key: 'profileImageUrl');
    referenceShopCode = await storage.read(key: 'referenceShopCode');
    profileFirstName = await storage.read(key: 'profileFirstName');
    profileLastName = await storage.read(key: 'profileLastName');
    profileCode = await storage.read(key: 'profileCode10');

    if (profileFirstName == null) profileFirstName = '';
    if (profileLastName == null) profileLastName = '';
    if (profileImageUrl == null) profileImageUrl = '';

    setState(() {
      _futureMCategory =
          postDio(server + 'm/mcategory/read', {'category': 'lv1'});
      _futureModel = postDio(server + 'm/goods/read', {'limit': _limit});
      // _futureSpecialOffer =
      //     postDio(server + 'm/goods/read', {'limit': 40, 'isHighlight': true});
      _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
      // _futureRotation = postDio('${mainRotationApi}read', {'limit': 10});
      _futureMainPopUp = postDio('${mainPopupHomeApi}read', {'limit': 10});
    });

    if (referenceShopCode != '') getCountOrder(); //
    getCountItemInCart();
    _getLocation();
    await _callReadPolicy();
    _buildMainPopUp();
    setState(() {});
  }

  _buildMainPopUp() async {
    var result = await post('${mainPopupHomeApi}read', {'limit': 100});

    if (result.length > 0) {
      var valueStorage = await storage.read(key: 'mainPopupDDPM');
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
              // c['username'] == userData.username &&
              c['date'].toString() ==
                  DateFormat("ddMMyyyy").format(date).toString() &&
              c['boolean'] == "true",
        );

        if (index == -1) {
          setState(() {
            hiddenMainPopUp = false;
          });
          return showDialog(
            barrierDismissible: false, // close outside
            context: context,
            builder: (_) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: MainPopupDialog(
                  model: _futureMainPopUp,
                  type: 'mainPopup',
                ),
              );
            },
          );
        } else {
          setState(() {
            hiddenMainPopUp = true;
          });
        }
      } else {
        setState(() {
          hiddenMainPopUp = false;
        });
        return showDialog(
          barrierDismissible: false, // close outside
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: MainPopupDialog(
                model: _futureMainPopUp,
                type: 'mainPopup',
              ),
            );
          },
        );
      }
    }
  }

  onTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  getCountItemInCart() async {
    //get amount item in cart.
    await postDio(server + 'm/cart/count', {}).then((value) async {
      if (value != null)
        setState(() {
          amountItemInCart = value['count'];
        });
    });
  }

  getCountOrder() async {
    //get amount item in cart.
    await postDio(server + 'm/cart/order/shop/count',
        {'referenceShopCode': referenceShopCode}).then((value) async {
      if (value != null)
        setState(() {
          amountItemStatusW = value['count'];
        });
    });
  }

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
    setState(() {
      _limit = 10;
    });
    _read();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    setState(() {
      _limit += 10;
    });
    setState(() {
      _futureModel = postDio(server + 'm/goods/read', {'limit': _limit});
    });

    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _getRotation() async {
    var response = await postDio('${mainRotationApi}read', {'limit': 10});

    return response;
  }

  _getLocation() async {
    // // print('currentLocation');
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.best);

    // // print('------ Position -----' + position.toString());

    // List<Placemark> placemarks = await placemarkFromCoordinates(
    //     position.latitude, position.longitude,
    //     localeIdentifier: 'th');
    // // print('----------' + placemarks.toString());

    // setState(() {
    //   latLng = LatLng(position.latitude, position.longitude);
    //   currentLocation = placemarks.first.administrativeArea;
    // });
  }

  _performActionOnNotification(Map<String, dynamic> message) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationList(
          title: 'แจ้งเตือน',
        ),
      ),
    );
  }

  Future<bool> _callConfirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}
