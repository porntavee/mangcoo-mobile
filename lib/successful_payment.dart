import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wereward/home.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/order_list.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'widget/header.dart';

class SuccessfulPaymentPage extends StatefulWidget {
  SuccessfulPaymentPage({Key key, this.productList: dynamic}) : super(key: key);

  final dynamic productList;
  @override
  _SuccessfulPaymentPageState createState() => _SuccessfulPaymentPageState();
}

class _SuccessfulPaymentPageState extends State<SuccessfulPaymentPage> {
  List<dynamic> model;
  Future<dynamic> _futureModel;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var tempData = List<dynamic>();
  bool latestCard = false;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header2(
        context,
        title: 'ช่องทางการชำระเงิน',
        customBack: true,
        func: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeMartPage(),
          ),
          (Route<dynamic> route) => false,
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(height: 50),
      Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF10BC37),
        ),
        child: Icon(
          Icons.check_rounded,
          size: 35,
          color: Colors.white,
        ),
      ),
      Text(
        'การชำระเงินเสร็จสมบูรณ์',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF10BC37),
        ),
      ),
      Text(
        'ขอบคุณที่เลือกใช้บริการ $appName\nเชิญเลือกสินค้าเพิ่มเติมต่อได้เลยค่ะ',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildButtonConfirm(
            'ดูรายการสั่งซื้อ',
            color: Theme.of(context).accentColor,
            press: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => OrderListPage())).then(
              (value) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HomeMartPage(),
                ),
                (Route<dynamic> route) => false,
              ),
            ),
          ),
          SizedBox(width: 20),
          buildButtonConfirm(
            'กลับหน้าหลัก',
            press: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeMartPage(),
              ),
              (Route<dynamic> route) => false,
            ),
          ),
        ],
      ),
    ];
  }

  buildButtonConfirm(String title,
      {Color color = const Color(0xFFED5643), Function press}) {
    return InkWell(
      onTap: () => press(),
      child: Container(
        height: 50,
        width: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: new Text(
          title,
          style: new TextStyle(
            fontSize: 15.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );
  }

  Padding buildPadding(List<Widget> children) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Container buildSpaceGrey({double height = 5.0}) {
    return Container(
      height: height,
      width: double.infinity,
      color: Theme.of(context).backgroundColor,
    );
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
    _futureModel =
        postDio('${server}m/manageAddress/read', {'isDefault': true});
  }
}
