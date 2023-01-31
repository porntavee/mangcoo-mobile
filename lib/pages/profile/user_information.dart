import 'package:easy_localization/easy_localization.dart';
import 'package:wereward/add_code.dart';
import 'package:wereward/chat_list.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/component/pdf_viewer_page.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/like.dart';
import 'package:wereward/manage_address.dart';
import 'package:wereward/my_credit_card.dart';
import 'package:wereward/notification_shop_list.dart';
import 'package:wereward/otp_login.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/pages/help_center/help_center.dart';
import 'package:wereward/pages/profile/connect_social.dart';
import 'package:wereward/pages/profile/detail_user_account.dart';
import 'package:wereward/pages/profile/edit_user_information.dart';
import 'package:wereward/accepted_policy.dart';
import 'package:wereward/pages/profile/following_list.dart';
import 'package:wereward/pages/sell/sell_page.dart';
import 'package:wereward/qr_scanner.dart';
import 'package:wereward/redeem.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/pages/profile/identity_verification.dart';
import 'package:wereward/pages/profile/setting_notification.dart';
import 'package:provider/provider.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

import 'change_language.dart';

class UserInformationPage extends StatefulWidget {
  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final storage = new FlutterSecureStorage();
  Future<dynamic> _futureProfile;
  Future<dynamic> _countLike;
  Future<dynamic> _countRedeemAll;
  Future<dynamic> _countRedeem;
  Future<dynamic> futureModel;
  Future<dynamic> _futureManageShop;
  String profileImageUrl = '';
  String referenceShopCode = '';
  String referenceShopName = '';
  String profilePhone = '';
  var profileFirstName;
  var profileLastName;

  bool isShop = false;

  int follower = 0;
  int following = 0;

  dynamic header = [
    {
      "barcodetop": "620063022984",
      "nameFrom": "Smile Meow",
      "addFrom":
          "5/10 ซอยอนามัยงามเจริญ25 แยก2-2 แขวงท่าข้าม,เขตบางขุนเทียน,จังหวัด กรุงเพทมหานคร 10150",
      "phone": "66886047613",
      "nameTo": "K.สิริธนกร ''พัสหย่อนหน้าบ้านได้เลยถ้ามีCODโทรก่อนส่งนะคะ''",
      "addTo":
          "บ้านเลขที่52/57 มบ.เทพราชนิเวศน์ ซ.3/1 ถ.นเรวศวร28 ต.เขาสามยอด,อำเภอเมืองลพบุรี,จังหวัดลพบุรี 15000",
      "charges": "572",
      "barcodeTable": "210720DEA2P8PF",
      "orderNo": "210720DEA2P8PF",
      "pickdate": "",
      "shipbydate": "22-07-2021",
      "note": "",
      "delivery1": "",
      "delivery2": "",
      "district": "อำเภอเมืองเลย",
      "districten": "H1-LRI0106-011",
      "qrcode": "https://ssp.we-builds.com/#/",
      "items": [
        {
          "name": "หนังสือ",
          "des": "",
          "number": "1",
        },
        {
          "name": "ปากกา",
          "des": "",
          "number": "10",
        },
        {
          "name": "ดินสอ",
          "des": "",
          "number": "2",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
      ],
    },
    {
      "barcodetop": "620063022985",
      "nameFrom": "Smile Meow",
      "addFrom":
          "5/10 ซอยอนามัยงามเจริญ25 แยก2-2 แขวงท่าข้าม,เขตบางขุนเทียน,จังหวัด กรุงเพทมหานคร 10150",
      "phone": "66886047613",
      "nameTo": "K.สิริธนกร ''พัสหย่อนหน้าบ้านได้เลยถ้ามีCODโทรก่อนส่งนะคะ''",
      "addTo":
          "บ้านเลขที่52/57 มบ.เทพราชนิเวศน์ ซ.3/1 ถ.นเรวศวร28 ต.เขาสามยอด,อำเภอเมืองลพบุรี,จังหวัดลพบุรี 15000",
      "charges": "572",
      "barcodeTable": "210720DEA2P8PF",
      "orderNo": "210720DEA2P8PF",
      "pickdate": "",
      "shipbydate": "22-07-2021",
      "note": "",
      "delivery1": "",
      "delivery2": "",
      "district": "อำเภอเมืองลพบุรี",
      "districten": "H1-LRI0106-011",
      "qrcode": "https://ssp.we-builds.com/#/",
      "items": [
        {
          "name": "หนังสือ",
          "des": "",
          "number": "1",
        },
        {
          "name": "ปากกา",
          "des": "",
          "number": "10",
        },
        {
          "name": "ดินสอ",
          "des": "",
          "number": "2",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
      ],
    },
    {
      "barcodetop": "620063022983",
      "nameFrom": "Smile Meow",
      "addFrom":
          "5/10 ซอยอนามัยงามเจริญ25 แยก2-2 แขวงท่าข้าม,เขตบางขุนเทียน,จังหวัด กรุงเพทมหานคร 10150",
      "phone": "66886047613",
      "nameTo": "K.สิริธนกร ''พัสหย่อนหน้าบ้านได้เลยถ้ามีCODโทรก่อนส่งนะคะ''",
      "addTo":
          "บ้านเลขที่52/57 มบ.เทพราชนิเวศน์ ซ.3/1 ถ.นเรวศวร28 ต.เขาสามยอด,อำเภอเมืองลพบุรี,จังหวัดลพบุรี 15000",
      "charges": "572",
      "barcodeTable": "210720DEA2P8PF",
      "orderNo": "210720DEA2P8PF",
      "pickdate": "",
      "shipbydate": "22-07-2021",
      "note": "",
      "delivery1": "",
      "delivery2": "",
      "district": "อำเภอเมืองลพบุรี",
      "districten": "H1-LRI0106-011",
      "qrcode": "https://ssp.we-builds.com/#/",
      "items": [
        {
          "name": "หนังสือ",
          "des": "",
          "number": "1",
        },
        {
          "name": "ปากกา",
          "des": "",
          "number": "10",
        },
        {
          "name": "ดินสอ",
          "des": "",
          "number": "2",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
        {
          "name": "ยางลบ",
          "des": "",
          "number": "4",
        },
      ],
    },
  ];

  @override
  void initState() {
    profileFirstName = '';
    profileLastName = '';
    _read();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _getProfile(),
            )
          ],
        ),
      ),
    );
  }

  _getProfile() {
    return FutureBuilder<dynamic>(
      future: _futureProfile,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['isShop'] == true)
            isShop = true;
          else
            isShop = false;
          return _screen();
        } else
          return _screen();
      },
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
      height: 140,
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 15),
                Container(
                  height: 70,
                  width: 70,
                  padding: EdgeInsets.all(profileImageUrl != '' ? 0.0 : 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: Hero(
                    tag: 'profileImage',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
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
                      Container(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                profileFirstName + ' ' + profileLastName,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (referenceShopCode != '')
                              StackTap(
                                onTap: () => _buildDialogManageShop(),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    referenceShopName,
                                    style: TextStyle(
                                        fontFamily: 'Kanit', fontSize: 16),
                                  ),
                                ),
                              ),
                          ],
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
                            ).then((value) => _read()),
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
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _getCount(_countLike, 'จำนวนถูกใจ'),
              _getCount(_countRedeem, 'จำนวนสิทธิ์ที่ใช้ไป'),
              _getCount(_countRedeemAll, 'จำนวนสิทธิ์ที่มีทั้งหมด'),
            ],
          ),
        ],
      ),
    );
  }

  _screen() {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(15),
      physics: ClampingScrollPhysics(),
      children: <Widget>[
        if (isShop) ..._buildListItemShop(),
        SizedBox(height: 10),
        Text(
          'การตั้งค่า',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
          ),
        ),
        SizedBox(height: 10),
        ..._buildContentCard(),
        SizedBox(height: 60),
        InkWell(
          onTap: () {
            // toastFail(context);
            logout(context);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.power_settings_new,
                color: themeChange.darkTheme ? Colors.white : Colors.red,
              ),
              Text(
                " ออกจากระบบ",
                style: new TextStyle(
                  fontSize: 12.0,
                  color: themeChange.darkTheme ? Colors.white : Colors.red,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Kanit',
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _buildListItemShop() {
    return <Widget>[
      Text(
        'สำหรับร้านค้า',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 13,
        ),
      ),
      SizedBox(height: 10),
      _buildRowContentButton(
        "assets/images/gift.png",
        "รายการรอจัดส่ง",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationShopListPage(),
          ),
        ),
        model: futureModel,
      ),
      _buildRowContentButton(
        "assets/images/gift.png",
        "สแกน QR รับสิทธิ์",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRViewPage(model: {'code': "", 'status': ''}),
          ),
        ),
        model: futureModel,
        // navigationForm: (dynamic model) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => QRViewPage(model: model),
        //     ),
        //   );
        // },
      ),
      _buildRowContentButton(
        "assets/images/gift.png",
        "กรอก Code รับสิทธิ์",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CodeViewPage(model: {'code': "", 'status': ''}),
          ),
        ),
        model: futureModel,
      ),
      _buildRowContentButton(
        "assets/images/gift.png",
        "ยันยืนการ Redeem",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RedeemPage(),
          ),
        ),
      ),
      _buildRowContentButton(
        "assets/images/gift.png",
        "สินค้าของฉัน",
        onTap: () => Navigator.push(
          context,
          fadeNav(SellPage(model: {
            'profileImageUrl': profileImageUrl,
            'profileFirstName': profileFirstName,
            'profileLastName': profileLastName
          })),
        ),
      ),
      SizedBox(height: 10),
    ];
  }

  _read() async {
    profileImageUrl = await storage.read(key: 'profileImageUrl');
    profilePhone = await storage.read(key: 'profilePhone');
    profileFirstName = await storage.read(key: 'profileFirstName');
    profileLastName = await storage.read(key: 'profileLastName');
    referenceShopCode = await storage.read(key: 'referenceShopCode');
    referenceShopName = await storage.read(key: 'referenceShopName');

    //read profile
    var profileCode = await storage.read(key: 'profileCode10');
    if (profileCode != '' && profileCode != null)
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
        _countLike = postDio("${server}m/like/count", {});
        _countRedeem = postDio("${server}m/redeem/countRedeem", {});
        _countRedeemAll = postDio("${server}m/redeem/countRedeemAll", {});
        futureModel =
            postDio('${server}m/redeem/read', {"profileCode": profileCode});

        if (referenceShopCode == null) referenceShopCode = '';
        if (referenceShopName == null) referenceShopName = '';
      });

    setState(() {
      _futureManageShop =
          postDio(server + 'm/manageShop/read', {"code": profileCode});
    });

    var followData = await postDio(server + 'm/follow/amount/read',
        {'referenceShopCode': referenceShopCode});

    setState(() {
      follower = followData['follower'];
      following = followData['following'];
    });
  }

  _buildContentCard() {
    return <Widget>[
      _buildRowContentButton(
        "assets/images/heart.png",
        "สิ่งที่ฉันถูกใจ",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LikePage(),
          ),
        ),
      ),
      _buildRowContentButton(
        "assets/images/gift.png",
        "พูดคุย",
        onTap: () => Navigator.push(
          context,
          fadeNav(ChatList()),
        ),
      ),
      if (!isShop)
        _buildRowContentButton(
          "assets/images/person.png",
          "บัญชีผู้ใช้งาน",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditUserInformationPage(),
            ),
          ),
        ),
      if (!isShop)
        _buildRowContentButton(
          "assets/images/person.png",
          "จัดการที่อยู่",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageAddressPage(),
            ),
          ),
        ),
      if (!isShop)
        _buildRowContentButton(
          "assets/images/id_card.png",
          "ยืนยันตัวตน",
          verify: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPLoginPage(
                userData: {'phone': profilePhone},
              ),
            ),
          ).then(
            (value) async =>
                {profilePhone = await storage.read(key: 'profilePhone')},
          ),
        ),
      if (!isShop)
        _buildRowContentButton(
          "assets/images/wallet.png",
          "การชำระเงิน",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyCreditCardPage(),
            ),
          ),
        ),
      _buildRowContentButton(
        "assets/images/id_card.png",
        tr('changeLanguage'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeLanguage(),
          ),
        ),
      ),
      // _buildRowContentButton(
      //   "assets/images/id_card.png",
      //   "การเชื่อมต่อ",
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ConnectSocialPage(),
      //     ),
      //   ),
      // ),
      // _buildRowContentButton(
      //   "assets/images/question_book.png",
      //   "แนะนำการใช้งาน",
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => HowToUseV2Page(navTo: () {}),
      //     ),
      //   ),
      // ),
      // _buildRowContentButton(
      //   "assets/images/lock.png",
      //   "เปลี่ยนรหัสผ่าน",
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ChangePasswordPage(),
      //     ),
      //   ),
      // ),
      _buildRowContentButton(
        "assets/images/double_paper.png",
        "เงื่อนไขและข้อกำหนดการใช้งาน",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AcceptedPolicyPage(),
          ),
        ),
      ),
      _buildRowContentButton(
        "assets/images/bell.png",
        "ตั้งค่าแอปพลิเคชัน",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingNotificationPage(),
          ),
        ),
      ),
      // _buildRowContentButton(
      //   "assets/images/link.png",
      //   "เชื่อมโยงบัญชี",
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ConnectSocialPage(),
      //     ),
      //   ),
      // ),
      // _buildRowContentButton(
      //   "assets/images/double_paper.png",
      //   "โหลดเอกสาร",
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       // builder: (context) => FlutterDemo(storage: CounterStorage()),
      //       builder: (context) => PdfViewerPagePost(
      //         path: '${serverReport}reportTest/reportTest',
      //         model: header,
      //       ),
      //     ),
      //   ),
      // ),
      _buildRowContentButton(
        "assets/images/bell.png",
        "ศูนย์ช่วยเหลือ",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HelpCenterPage(),
          ),
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 5),
        child: Text(
          versionName,
          style: new TextStyle(
            // fontSize: 9.0,
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
          textAlign: TextAlign.right,
        ),
      ),
    ];
  }

  _buildRowContentButton(
    String urlImage,
    String title, {
    Function onTap,
    Future<dynamic> model,
    bool verify = false,
  }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    Color color =
        themeChange.darkTheme ? Colors.white : Theme.of(context).accentColor;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.grey[200],
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 36),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border(
          //   bottom: BorderSide(
          //     color: themeChange.darkTheme ? Colors.white : Theme.of(context).backgroundColor,
          //     width: 1,
          //   ),
          // ),
        ),
        alignment: Alignment.bottomLeft,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color,
                  ),
                  child: Image.asset(
                    urlImage,
                    color: themeChange.darkTheme
                        ? Theme.of(context).accentColor
                        : Colors.white,
                  ),
                  width: 35.0,
                  height: 35.0,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: new TextStyle(
                        fontSize: 13.0,
                        color: color,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                ),
                if (verify && profilePhone != '')
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.red,
                    size: 15,
                  ),
                if (verify && profilePhone != '')
                  Text(
                    ' ยืนยันตัวตนสำเร็จ',
                    style: TextStyle(
                        fontFamily: 'Kanit', fontSize: 11, color: Colors.red),
                  ),
                if (verify && profilePhone == '')
                  Icon(
                    Icons.info_outline,
                    color: Colors.red,
                    size: 15,
                  ),
                if (verify && profilePhone == '')
                  Text(
                    ' ยังไม่ยืนยันตัวตน',
                    style: TextStyle(
                        fontFamily: 'Kanit', fontSize: 11, color: Colors.red),
                  ),
                SizedBox(width: 8),
                Container(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    "assets/images/arrow_right.png",
                    height: 20.0,
                    width: 20.0,
                    color: color,
                  ),
                ),
              ],
            ),
            Container(
              height: 1.5,
              color: themeChange.darkTheme
                  ? Colors.white
                  : Theme.of(context).backgroundColor,
              margin: EdgeInsets.only(left: 45, right: 5),
            )
          ],
        ),
      ),
    );
  }

  _getdata() {
    return FutureBuilder<dynamic>(
        future: _futureProfile,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return FlatButton(
              padding: EdgeInsets.all(0.0),
              child: _buildRowContentButton(
                "assets/images/paper_check_list.png",
                snapshot.data['idcard'] != ""
                    ? "ข้อมูลสมาชิก"
                    : "ลงทะเบียนข้อมูลสมาชิก",
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // ignore: missing_required_param
                  builder: (context) => IdentityVerificationPage(
                    title: snapshot.data['idcard'] != ""
                        ? "ข้อมูลสมาชิก"
                        : "ลงทะเบียนข้อมูลสมาชิก",
                  ),
                  // builder: (context) => PolicyIdentityVerificationPage(),
                ),
              ).then((value) => {} //readStorage(),
                  ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                color: Colors.white,
                child: dialogFail(context, reloadApp: true),
              ),
            );
          } else {
            return Center(
              child: Container(),
            );
          }
        });
  }

  _getCount(Future<dynamic> dataCount, String des) {
    return FutureBuilder<dynamic>(
      future: dataCount,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // print('---------${snapshot.data}');
        if (snapshot.hasData) return _datacount(snapshot.data.toString(), des);
        if (snapshot.hasError)
          return _datacount("0", des);
        else
          return _datacount("0", des);
      },
    );
  }

  _datacount(String count, String des) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        Text(
          des,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  _buildDialogManageShop() async {
    return await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        return SafeArea(
          child: FutureBuilder(
            future: _futureManageShop,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                double height = 70;
                height =
                    double.parse(((snapshot.data.length * 50 + 20)).toString());
                return CustomAlertDialog(
                  height: height,
                  contentPadding: EdgeInsets.all(10),
                  content: Column(
                    children: snapshot.data
                        .map<Widget>(
                          (e) => StackTap(
                            onTap: () => {
                              storage.write(
                                key: 'referenceShopCode',
                                value: e['shopCode'],
                              ),
                              storage.write(
                                key: 'referenceShopName',
                                value: e['referenceShopName'],
                              ),
                              _read(),
                              Navigator.pop(context)
                            },
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(e['referenceShopName']),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              } else {
                return CustomAlertDialog(
                  contentPadding: EdgeInsets.all(10),
                  content: Container(),
                );
              }
            },
          ),
        );
      },
    );
  }
}
