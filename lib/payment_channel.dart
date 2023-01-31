import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/successful_payment.dart';
import 'widget/header.dart';

class PaymentChannelPage extends StatefulWidget {
  PaymentChannelPage({Key key, this.model: dynamic}) : super(key: key);

  final dynamic model;
  @override
  _PaymentChannelPageState createState() => _PaymentChannelPageState();
}

class _PaymentChannelPageState extends State<PaymentChannelPage> {
  dynamic model;

  var tempData = List<dynamic>();
  bool latestCard = false;
  int totalPrice = 0;

  @override
  void initState() {
    setPrice();
    super.initState();
  }

  setPrice() async {
    model = await widget.model;
    setState(() {
      model.forEach(
          (item) => totalPrice = totalPrice + (item['netPrice'] * item['qty']));
    });
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
        appBar: header2(
          context,
          title: 'ช่องทางการชำระเงิน',
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                child: ListView(
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
      buildOrderDetails(),
      buildSpaceGrey(),
      SizedBox(height: 10),
      buildPadding(buildLatestCard()),
      SizedBox(height: 10),
      buildSpaceGrey(),
      buildPadding(buildListPayment()),
      SizedBox(height: 10),
      buildSpaceGrey(height: 60),
      buildButtonConfirm(),
    ];
  }

  buildButtonConfirm() {
    return InkWell(
      onTap: () => payment(),
      child: Container(
        height: 40,
        color: Color(0xFFED5643),
        alignment: Alignment.center,
        child: new Text(
          'ชำระเงิน',
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

  List<Widget> buildLatestCard() {
    return <Widget>[
      Text(
        'วิธีที่ใช้ในการชำระเงินครั้งล่าสุด',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/visa.png', width: 25, height: 25),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '1234 12** **** 1234\n',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: const <TextSpan>[
                  TextSpan(
                    text: 'บัตรเครดิต/บัตรเดบิต',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => latestCard = !latestCard),
            child: Container(
              height: 25,
              width: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: latestCard ? Color(0xFFED5643) : Colors.transparent,
                border: Border.all(
                  width: 1,
                  color: latestCard ? Color(0xFFED5643) : Colors.grey,
                ),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          )
        ],
      )
    ];
  }

  List<Widget> buildListPayment() {
    return <Widget>[
      Text(
        'ช่องทางการชำระเงิน',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 15),
      buildItemPayment('assets/images/visa.png', 'บัตรเครดิต / บัตรเดบิต'),
      SizedBox(height: 15),
      buildItemPayment('assets/images/wallet_blue.png', 'ผ่อนชำระ'),
      SizedBox(height: 15),
      buildItemPayment('assets/images/calendar_blue.png',
          'อินเทอร์เน็ตแบงก์กิ้ง / โมบายแบงก์กิ้ง'),
      SizedBox(height: 15),
      buildItemPayment('assets/images/shop_blue.png', 'ชำระเงินผ่านเคาน์เตอร์'),
    ];
  }

  GestureDetector buildItemPayment(String image, String title) {
    return GestureDetector(
      onTap: () => {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(image, width: 30, height: 30),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 15),
        ],
      ),
    );
  }

  Container buildOrderDetails() {
    return Container(
      height: 96,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              text: priceFormat.format(totalPrice),
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: const <TextSpan>[
                TextSpan(
                  text: ' บาท',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'รายละเอียดคำสั่งซื้อ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          )
        ],
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

  payment() async {
    final storage = new FlutterSecureStorage();
    final profileCode = await storage.read(key: 'profileCode10');
    Dio dio = new Dio();
    if (model.length == 1 && model[0]['status'] == 'P') {
      model[0]['profileCode'] = profileCode;
      return await dio.post(server + 'm/cart/create', data: model[0]).then(
            (response) => {
              if (response.data['status'] == 'S')
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuccessfulPaymentPage(),
                  ),
                )
            },
          );
    }

    model.map((e) {
      e['status'] = 'P';
    }).toList();

    return await dio.post(server + 'm/cart/update', data: model).then(
          (response) => {
            if (response.data['status'] == 'S')
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuccessfulPaymentPage(),
                ),
              )
          },
        );
  }
}
