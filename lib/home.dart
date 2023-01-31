import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:wereward/accumulate_reward_points.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/component/material/form_content.dart';
import 'package:wereward/component/menu/list_content.dart';
import 'package:wereward/component/menu/list_new_reward.dart';
import 'package:wereward/coupon.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/login.dart';
import 'package:wereward/pages/policy_v2.dart';
import 'package:wereward/product.dart';
import 'package:wereward/new_reward.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/pages/profile/user_information.dart';
import 'package:wereward/promotion.dart';
import 'package:wereward/privilege.dart';
import 'package:wereward/search_list.dart';
import 'package:wereward/shop.dart';
import 'package:wereward/shop_old.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/pages/notification/notification_list.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/shared/api_provider.dart';
import 'how_to_use_v2.dart';
import 'pages/main_popup/dialog_main_popup.dart';
import 'shared/notification_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<HomePage> {
  final storage = new FlutterSecureStorage();
  DateTime currentBackPressTime;
  // PageController pageController;

  Future<dynamic> _futureBanner;
  Future<dynamic> _futureProfile;
  Future<dynamic> _futureOrganizationImage;
  Future<dynamic> _futureMenu;
  Future<dynamic> _futureRotation;
  Future<dynamic> _futureAboutUs;
  Future<dynamic> _futureMainPopUp;
  Future<dynamic> _futureVerify;
  Future<dynamic> _futureNews;
  Future<dynamic> _futurePrivilege;
  Future<dynamic> _futureKnowledge;
  Future<dynamic> _futureContact;
  Future<dynamic> _futureNewsCategory;
  Future<dynamic> _futurePromotionCategory;
  Future<dynamic> _futurePromotion;
  Future<dynamic> _futurePoiCategory;
  Future<dynamic> _futurePartnerCategory;

  bool isDialog = false;
  bool clickArrow = false;
  bool networkConnected = false;

  String currentLocation = '-';
  String profileImageUrl = '';
  String profileFirstName = '';
  String profileLastName = '';
  String profileCode = '';
  final seen = Set<String>();
  List unique = [];
  List imageLv0 = [];
  bool scBool = true;

  bool notShowOnDay = false;
  bool hiddenMainPopUp = false;
  bool checkDirection = false;
  LatLng latLng = LatLng(0, 0);

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

  @override
  void initState() {
    _read();
    _scrollController = ScrollController();

    super.initState();
    // NotificationService.instance.start();
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);

    _targetsAdd();
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
      // extendBody: true,
      // extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
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
                  color: Colors.white,
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
            onWillPop: confirmExit),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Future<bool> confirmExit() {
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

  _buildBottomNavBar() {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      // padding: EdgeInsets.only(bottom:15),
      height: (MediaQuery.of(context).size.height * 8.5) / 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
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
          _buildTap(0, 'Home', 'assets/images/home.png', key: keyButton7),
          _buildTap(1, 'Promotion', 'assets/images/tag.png', key: keyButton8),
          _buildTap(2, 'My Coupon', 'assets/images/coupon.png',
              key: keyButton9),
          profileCode != '' && profileCode != null
              ? _buildTap(
                  3,
                  'Account',
                  profileImageUrl,
                  key: keyButton10,
                  isNetwork: true,
                )
              : _buildTap(3, 'login', 'assets/images/profile.png',
                  key: keyButton10)

          // FutureBuilder(
          //   future: ,
          //   builder: (context, profileData) {
          //   if (profileData.hasData) {
          //     return _buildTap(
          //       3,
          //       'Account',
          //       'assets/images/profile.png',
          //       // isNetwork: true,
          //       key: keyButton10,
          //     );
          //   } else {
          //     return
          //   }
          // }),
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
                padding: EdgeInsets.only(
                  top: 5,
                ),
                child: Column(
                  children: [
                    isNetwork
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: loadingImageNetwork(
                              pathImage,
                              height: 30,
                              width: 30,
                              isProfile: true,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            pathImage,
                            height: 30,
                            width: 30,
                            color: color,
                          ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12,
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
      enablePullUp: false,
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

  _buildHeadMain() {
    return Container(
      color: Theme.of(context).primaryColor,
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
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      appName,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    key: keyButton,
                    onTap: () {
                      // _buildDialogDarkMode();

                      // showTutorial();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HowToUseV2Page(navTo: () {}),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/question_mark.png',
                        height: 30,
                        width: 30,
                      ),
                      // child: Icon(
                      //   Icons.search,
                      //   size: 29,
                      // ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              InkWell(
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
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 7),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        'อะไรคุณกำลังมองหา',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildListMenuMain() {
    return <Widget>[
      SizedBox(height: 10),
      Column(
        children: [
          // _futureBuiderGrid1(),
          _buildListButtonMainMenu(),
        ],
      ),
      SizedBox(height: 5),
      ListNewPrivilegePage(
        key: keyButton5,
        title: 'รางวัลมาใหม่',
        model: _futureNews,
        navigationForm: (dynamic model) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormContent(
                api: 'news',
                model: model,
                urlRotation: rotationNewsApi,
              ),
            ),
          );
        },
        navigationList: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewRewardPage(),
            ),
          );
        },
      ),
      SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.only(left: 15, bottom: 5),
        child: Text(
          'แนะนำ',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontFamily: 'Kanit',
            fontSize: 13,
          ),
        ),
      ),
      _buildRotation(),
      SizedBox(height: 10),
      // FutureBuilder(
      //   future: _futurePartnerCategory,
      //   builder: (context, partnerData) {
      //     if (partnerData.hasData) {
      //       return ListContentFullImageHorizontal(
      //         key: keyButton6,
      //         title: 'Partner Promotion',
      //         model: _futurePartnerCategory,
      //         cardWidth: 92,
      //         hasImageCenter: false,
      //         hasDescription: false,
      //         navigationForm: (dynamic model) {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               // builder: (context) => StoryScreen(stories: stories)
      //               builder: (context) => MoreStories(model: model),
      //             ),
      //           );
      //         },
      //       );
      //     } else if (partnerData.hasError) {
      //       return Container();
      //     } else {
      //       return Container(height: 150);
      //     }
      //   },
      // ),
      ListCircle(
        title: 'Shop',
        model: _futurePoiCategory,
        navigationForm: (dynamic model, bool onHover) {
          if (onHover)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopPage(
                  code: model['code'],
                ),
              ),
            );
          else
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopOldPage(
                  code: model['code'],
                ),
              ),
            );
        },
        // navigationList: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => ShopPage(
        //           // code: model['code'],
        //           // model: model,
        //           ),
        //     ),
        //   );
        // },
      ),
      // BuildContact(
      //   model: _futureContact,
      //   menuModel: _futureMenu,
      // ),
      SizedBox(
        height: 10,
      )
    ];
  }

  _buildListButtonMainMenu() {
    return Row(
      children: [
        Expanded(
          key: keyButton2,
          flex: 1,
          child: _buidItemGrid(
            'สิทธิพิเศษเฉพาะคุณ',
            'assets/images/gift.png',
            onTap: () {
              _callReadPolicyPrivilege();
            },
          ),
        ),
        Expanded(
          key: keyButton3,
          flex: 1,
          child: _buidItemGrid(
            'สะสมคะแนน',
            'assets/images/crown.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      AccumulateRewardPointsPage(),
                ),
              );
            },
          ),
        ),
        Expanded(
          key: keyButton4,
          flex: 1,
          child: _buidItemGrid('แลกสินค้า', 'assets/images/package_box.png',
              onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductPage(),
              ),
            );
          }),
        ),
      ],
    );
  }

  _buidItemGrid(String title, String image,
      {Function onTap, bool isImageNetwork = false}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        height: 74,
        child: Column(
          children: [
            Container(
              height: 50,
              child: isImageNetwork
                  ? Image.network(
                      image,
                      height: 30,
                      width: 30,
                      // color: Color(0xFFED5643),
                    )
                  : Image.asset(
                      image,
                      height: 30,
                      width: 30,
                      color: Theme.of(context).accentColor,
                    ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    color: Theme.of(context).accentColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            )
          ],
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
        child: CarouselBanner(model: _futureRotation, url: 'main/'),
      ),
    );
  }

  _buildDialogDarkMode() async {
    return await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        final themeChange = Provider.of<DarkThemeProvider>(context);
        return CustomAlertDialog(
          contentPadding: EdgeInsets.all(10),
          content: new Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    currentTabIndex = 3;
                    pageController.jumpToPage(3);
                    Navigator.pop(context);
                  });
                },
                child: Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Container(
                    //   width: 25,
                    //   height: 25,
                    //   alignment: Alignment.center,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: themeChange.darkTheme
                    //         ? Color(0xFFED8554)
                    //         : Color(0xFFF69E7B),
                    //   ),
                    //   child: Text(
                    //     'W',
                    //     style: TextStyle(
                    //       fontFamily: 'Kanit',
                    //       fontSize: 12,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileFirstName != ''
                              ? profileFirstName + ' ' + profileLastName
                              : 'เข้าสู่ระบบ',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 12,
                          ),
                        ),
                        if (profileFirstName != '')
                          Text(
                            'จัดการบัญชีของคุณ',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 12,
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 0.5,
                color: themeChange.darkTheme
                    ? Color(0xFFE4E4E4)
                    : Color(0xFF707070),
              ),
              SizedBox(height: 10),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    themeChange.darkTheme = themeChange.darkTheme;
                    clickArrow = !clickArrow;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Container(
                      width: 25,
                      height: 25,
                      padding: EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeChange.darkTheme
                            ? Colors.black
                            : Color(0xFF707070),
                      ),
                      child: Icon(
                        themeChange.darkTheme ? Icons.bedtime : Icons.wb_sunny,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'จัดการโหมด',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    new Container(
                      padding: EdgeInsets.all(2),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        clickArrow
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: themeChange.darkTheme
                            ? Colors.white
                            : Color(0xFF707070),
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2),
              if (clickArrow)
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      themeChange.darkTheme = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Container(
                        width: 25,
                        height: 25,
                        child: Icon(
                          Icons.wb_sunny,
                          color: themeChange.darkTheme
                              ? Color(0xFF707070)
                              : Color(0xFFF69E7B),
                          size: 12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'โหมดกลางวัน',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 2),
              if (clickArrow)
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      themeChange.darkTheme = true;
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Container(
                        width: 25,
                        height: 25,
                        child: Icon(
                          Icons.bedtime,
                          color: themeChange.darkTheme
                              ? Color(0xFFED8554)
                              : Color(0xFF707070),
                          size: 12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'โหมดกลางคืน',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ).then((val) {
      setState(() {
        isDialog = false;
      });
    });
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
                  builder: (context) => HomePage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else
      _buildMainPopUp();
  }

  checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
      return toastFail(context, text: 'not connected');
    }
  }

  Future<Null> _callReadPolicyPrivilege() async {
    var policy = await postDio(server + "m/policy/read",
        {"category": "marketing", "skip": 0, "limit": 10});

    if (profileCode != '' && profileCode != null && policy.length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          // ignore: missing_required_param
          // builder: (context) => PolicyIdentityVerificationPage(),
          builder: (context) => PolicyV2Page(
            category: 'marketing',
            navTo: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivilegePage(),
                ),
              );
            },
          ),
        ),
      );

      // if (!isPolicyFasle) {
      //   logout(context);
      //   _onRefresh();
      // }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrivilegePage(),
        ),
      );
    }
  }

  getProfileData() async {
    profileCode = await storage.read(key: 'profileCode10');
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

      var token = await storage.read(key: 'token');
      if (token != '' && token != null)
        postDio('${server}m/v2/register/token/create',
            {'token': token, 'profileCode': profileCode});
    }

    _futureMenu = postDio('${menuApi}read', {'limit': 100});
    _futureNews = postDio('${newsApi}read', {'limit': 10});
    _futurePartnerCategory =
        postDio('${partnerCategoryApi}read', {'limit': 10});
    _futurePromotion = postDio('${promotionApi}read', {'limit': 10});
    _futurePoiCategory = postDio('${poiCategoryApi}read', {'limit': 100});
    _futureKnowledge = postDio('${knowledgeApi}read', {'limit': 10});
    _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
    _futureRotation = postDio('${mainRotationApi}read', {'limit': 10});
    _futureMainPopUp = postDio('${mainPopupHomeApi}read', {'limit': 10});
    _futureContact = postDio('${contactApi}read', {'limit': 10});
    _futureAboutUs = postDio('${aboutUsApi}read', {});
    _futurePrivilege = postDio('${privilegeApi}read', {'limit': 10});

    _futureNewsCategory = postDio('${newsCategoryApi}read', {'limit': 100});
    _futurePromotionCategory = postDioCategory(
      '${promotionCategoryApi}read',
      {
        'skip': 0,
        'limit': 100,
      },
    );

    // _buildMainPopUp();
    _getLocation();
    _callReadPolicy();
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

      // return showDialog(
      //   barrierDismissible: false, // close outside
      //   context: context,
      //   builder: (_) {
      //     return WillPopScope(
      //       onWillPop: () {
      //         return Future.value(false);
      //       },
      //       child: MainPopupDialog(
      //         model: _futureMainPopUp,
      //         type: 'mainPopup',
      //       ),
      //     );
      //   },
      // );

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

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
    _read();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _getLocation() async {
    // print('currentLocation');
    // fixflutter2 Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.best);

    // print('------ Position -----' + position.toString());

    // fixflutter2 List<Placemark> placemarks = await placemarkFromCoordinates(
    //     position.latitude, position.longitude,
    //     localeIdentifier: 'th');
    // print('----------' + placemarks.toString());

    setState(() {
      // fixflutter2 latLng = LatLng(position.latitude, position.longitude);
      // fixflutter2 currentLocation = placemarks.first.administrativeArea;
    });
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

  void showInSnackBar(String value) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text(value),
        duration: Duration(hours: 1),
      ),
    );
  }

  void showTutorial() {
    TutorialCoachMark tutorial = TutorialCoachMark(context,
        targets: targets, // List<TargetFocus>
        colorShadow: Colors.red, // DEFAULT Colors.black
        // alignSkip: Alignment.bottomRight,
        // textSkip: "SKIP",
        // paddingFocus: 10,
        // focusAnimationDuration: Duration(milliseconds: 500),
        // pulseAnimationDuration: Duration(milliseconds: 500),
        onFinish: () {},
        onClickTarget: (target) {},
        onSkip: () {})
      ..show();

    // tutorial.skip();
    // tutorial.finish();
    // tutorial.next(); // call next target programmatically
    // tutorial.previous(); // call previous target programmatically
  }

  _targetsAdd() {
    targets.add(
      TargetFocus(
        identify: "Target",
        keyTarget: keyButton,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "ปุ่มสำหรับคำแนะนำการใช้งาน",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton1,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "ค้นหาสินค้าหรือสิ่งที่สนใจ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 2",
        keyTarget: keyButton2,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "สิทธิ์พิเศษเฉพาะคุณ เพื่อรับรางวัล",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 3",
        keyTarget: keyButton3,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "สะสมคะแนน เพื่อรับของรางวัล",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 4",
        keyTarget: keyButton4,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "คูปองแลกสินค้า ที่คัดสรรมาเฉพาะคุณ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 5",
        keyTarget: keyButton5,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "สิทธิ์พิเศษเฉพาะคุณ ที่น่าสนใจ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 6",
        keyTarget: keyButton6,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "โปรโมชันพิเศษส่งตรงจาก พาร์ทเนอร์",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 7",
        keyTarget: keyButton7,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "ทางลัดสู่หน้าหลัก",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 8",
        keyTarget: keyButton8,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "ทางลัดสู่หน้าสิทธิพิเศษ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 9",
        keyTarget: keyButton9,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "คูปองของฉันทั้งหมด",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 10",
        keyTarget: keyButton10,
        color: Colors.transparent,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "คุณสามารถแก้ไขโปรไฟล์ได้ที่นี่",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF000000),
                          fontSize: 13.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
