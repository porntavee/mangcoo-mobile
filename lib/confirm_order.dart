import 'dart:async';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:wereward/manage_address.dart';
import 'package:wereward/otp_login.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/payment_credit_success.dart';
import 'package:wereward/payment_method_confirm_order.dart';
import 'package:wereward/qr_payment.dart';
import 'package:wereward/receipt_and_tax_invoice.dart';
import 'package:wereward/select_coupon.dart';
import 'package:wereward/shared/api_payment.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';
import 'widget/header.dart';

class ConfirmOrderPage extends StatefulWidget {
  ConfirmOrderPage(
      {Key key, this.code, this.productList: dynamic, this.from: 'cart'})
      : super(key: key);

  final String code;
  final dynamic productList;
  final String from;
  @override
  _ConfirmOrderPageState createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  List<dynamic> model;
  Future<dynamic> _futureModel;

  ScrollController scrollController = new ScrollController();
  final storage = new FlutterSecureStorage();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Dio dio = new Dio();
  var uuid = Uuid();
  bool loading = false;
  double priceUsd = 0.0;

  var tempData = List<dynamic>();
  bool switchPoint = false;
  String paymentType = 'O';
  dynamic paymentMethod = {'type': '', 'title': '', 'data': ''};
  double totalPrice = 0.0;
  double sumPrice = 0.0;
  String name = '';
  String phone = '';
  dynamic address = {
    'code': '',
    'address': '',
    'province': '',
    'district': '',
    'subDistrict': '',
    'postalCode': ''
  };
  bool hasAddress = false;

  @override
  void initState() {
    _callRead();
    widget.productList.forEach(
        (item) => totalPrice = totalPrice + (item['netPrice'] * item['qty']));

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
        appBar: header2(
          context,
          title: 'ข้อมูลการสั่งซื้อ',
        ),
        backgroundColor: Colors.white,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              ListView(
                children: _buildList(),
              ),
              _buildBtnBottom(),
              if (loading) loadingWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black.withOpacity(0.5),
      alignment: Alignment.center,
      child: Container(
        height: 100,
        width: 100,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: CircularProgressIndicator(
          strokeWidth: 8,
          backgroundColor: Theme.of(context).accentColor,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Positioned _buildBtnBottom() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 65 + MediaQuery.of(context).padding.bottom,
        width: double.infinity,
        child: Row(
          children: [
            InkWell(
              onTap: () => {},
              child: Container(
                width: 128,
                alignment: Alignment.center,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'รวมทั้งหมด',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      priceFormat.format(sumPrice),
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalPriceUsd(sumPrice),
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: StackTap(
                splashColor: Colors.black.withOpacity(0.5),
                onTap: () => {
                  if (paymentMethod['type'] != '')
                    {
                      if (paymentMethod['type'] == 'TQ') paymentTQ(),
                      if (paymentMethod['type'] == 'CC') paymentCC()
                    }
                  else
                    {toastFail(context, text: 'กรุณาเลือกวิธีการชำระเงิน')}
                },
                child: Container(
                  color: Color(0xFFE84C10),
                  alignment: Alignment.center,
                  child: Text(
                    'ซื้อสินค้า',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      _buildItemAddress(),
      // buildAddress(),
      // buildSpaceGrey(),
      // buildPadding(buildPaymentType()),
      buildSpaceGrey(),
      SizedBox(height: 10),
      ...widget.productList.map((item) => buildPadding(buildProductList(item))),
      buildSpaceGrey(),
      SizedBox(height: 10),
      // buildPadding(buildCouponAndReceipt()),
      // buildSpaceGrey(),
      buildPadding(buildCost()),
      buildSpaceGrey(),
      buildPaymentMethod(),
      buildPadding(buildSum()),
      buildSpaceGrey(),
      buildSpaceGrey(),
      SizedBox(height: 60 + MediaQuery.of(context).padding.bottom)
    ];
  }

  Widget buildPaymentMethod() {
    return StackTap(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentMethodConfirmOrder(method: paymentMethod),
        ),
      ).then(
        (value) => {if (value != null) setState(() => paymentMethod = value)},
      ),
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'วิธีการชำระเงิน',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
                // color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                paymentMethod['type'] != ''
                    ? paymentMethod['title']
                    : 'เลือกวิธีการชำระเงิน',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  color: Color(0xFFED5643),
                ),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildCost() {
    return <Widget>[
      SizedBox(height: 10),
      buildTextRow('ค่าใช้จ่าย', 'บาท', header: true),
      buildTextRow('ค่าสินค้า', priceFormat.format(totalPrice)),
      buildTextRow('ค่าขนส่ง', '40'),
      // buildTextRow('คูปอง', '-40'),
      // buildTextRow('We point', switchPoint ? '-9' : '0'),
      SizedBox(height: 10),
    ];
  }

  List<Widget> buildSum() {
    sumPrice = totalPrice + 40;
    if (switchPoint) sumPrice = sumPrice - 9;
    var receivePoint = (sumPrice / 100).floor();
    return <Widget>[
      SizedBox(height: 10),
      buildTextRow('สรุป', 'บาท', header: true),
      buildTextRow('ยอดชำระ', priceFormat.format(sumPrice)),
      // buildTextRow('We Point', priceFormat.format(receivePoint)),
      SizedBox(height: 10),
    ];
  }

  Row buildTextRow(String title, String value, {bool header = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
            fontWeight: header ? FontWeight.bold : FontWeight.normal,
            color: header ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  List<Widget> buildCouponAndReceipt() {
    return <Widget>[
      buildButtomRow(
        'เอกสารใบเสร็จรับเงิน',
        'ใบเสร็จรับเงิน ()',
        nav: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptAndTaxInvoicePage(),
          ),
        ).then((value) => {if (value == 'success') {}}),
      ),
      SizedBox(height: 10),
      buildButtomRow(
        'คูปอง',
        'ส่วนลด 50 บาท',
        nav: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectCouponPage(),
          ),
        ).then((value) => {if (value == 'success') {}}),
      ),
      SizedBox(height: 10),
      buildButtomRow(
        'คะแนน',
        'We Point คงเหลือ 950 คะแนนสามารถใช้ We Point แทนส่วนลดสูงสุด 900 คะแนน (มูลค่าเท่ากับ 9 บาท)',
        isSwitch: true,
        nav: () => {},
      ),
      SizedBox(height: 10),
    ];
  }

  InkWell buildButtomRow(
    String title,
    String subTitle, {
    Function nav,
    bool isSwitch = false,
  }) {
    return InkWell(
      onTap: () => nav(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subTitle,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          isSwitch
              ? Switch(
                  value: switchPoint,
                  onChanged: (value) {
                    setState(() {
                      switchPoint = !switchPoint;
                    });
                  },
                  activeTrackColor: Theme.of(context).accentColor,
                  activeColor: Color(0xFFFFFFFF),
                )
              : Icon(Icons.arrow_forward_ios_rounded, size: 15),
        ],
      ),
    );
  }

  List<Widget> buildProductList(model) {
    return <Widget>[
      Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45),
                color: Theme.of(context).accentColor,
              ),
              child: Text(
                // 'we build',
                '${model['referenceShopName']}',
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: loadingImageNetwork(
                    model['imageUrl'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model['title'],
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${priceFormat.format(model['price'] * model['qty']) + " บาท"}',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Kanit',
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${priceFormat.format(model['netPrice'] * model['qty']) + " บาท"}',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 10),
                          if (model['netPriceUsd'] != null)
                            if (model['netPrice'] != model['netPriceUsd'])
                              Text(
                                '${priceFormat.format(model['netPriceUsd'] * model['qty']) + " usd"}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                        ],
                      ),
                      Container(
                        height: 30,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1),
                          color: Colors.white,
                        ),
                        child: Text(
                          '${model['title']}',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: 10),
      buildSpaceGrey(),
    ];
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

  List<Widget> buildPaymentType() {
    return <Widget>[
      SizedBox(height: 10),
      Text(
        'ช่องทางการชำระเงิน',
        style: TextStyle(fontFamily: 'Kanit', fontSize: 13),
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          {'display': 'ชำระเงินออนไลน์', 'value': 'O'},
          {'display': 'ชำระเงินปลายทาง', 'value': 'C'}
        ]
            .map((e) => InkWell(
                  onTap: () => setState(() => paymentType = e['value']),
                  child: Container(
                    height: 70,
                    // width: 170,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.only(right: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: paymentType == e['value']
                            ? Color(0xFFED5643)
                            : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: paymentType == e['value']
                          ? Color(0xFFED5643)
                          : Colors.white,
                    ),
                    child: Text(
                      e['display'],
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        color: paymentType == e['value']
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
      SizedBox(height: 20),
    ];
  }

  Container buildSpaceGrey() {
    return Container(
      height: 5,
      width: double.infinity,
      color: Theme.of(context).backgroundColor,
    );
  }

  FutureBuilder buildAddress() {
    return FutureBuilder(
      future: _futureModel,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Container();
            // return _buildItemAddress(snapshot.data[0]);
          } else {
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageAddressPage(),
                ),
              ),
              child: Container(
                height: 120,
                child: Center(
                  child: Text(
                    'ยังไม่มีที่อยู่ เพิ่มที่อยู่',
                    style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
                  ),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Container(
            height: 120,
            child: Center(
              child: InkWell(
                onTap: () => _onLoading(),
                child: Text('เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง'),
              ),
            ),
          );
        } else {
          return Column(
            children: [
              LoadingTween(
                height: 100,
                width: double.infinity,
              ),
              SizedBox(height: 10)
            ],
          );
        }
      },
    );
  }

  InkWell _buildItemAddress() {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageAddressPage(showEdit: true),
          ),
        ).then(
          (value) async => {
            if (value['status'] == '1') // เลือกที่อยู่
              {
                hasAddress = true,
                setState(
                  () {
                    name = value['title'];
                    phone = value['phone'];
                    address = {
                      'code': value['code'],
                      'address': value['address'],
                      'subDistrict': value['subDistrictTitle'],
                      'district': value['districtTitle'],
                      'province': value['provinceTitle'],
                      'postalCode': value['postalCode'],
                    };
                  },
                ),
              }
            else if (value['status'] == '2') // ไม่มีที่อยู่
              {
                setState(
                  () {
                    name = '';
                    phone = '';
                    address = {
                      'code': '',
                      'address': '',
                      'province': '',
                      'district': '',
                      'subDistrict': '',
                      'postalCode': ''
                    };
                  },
                ),
              }
          },
        );
      },
      child: StatefulBuilder(
        builder: (context, setState) => Container(
          constraints: BoxConstraints(minHeight: 105),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: hasAddress
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${name + ' ' + phone}",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          Text(
                            '${address['address']} ${address['subDistrict']} \n${address['district']} ${address['province']} \n${address['postalCode']}',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              color: Color(0xFF707070),
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          "เพิ่มที่อยู่จัดส่งของคุณของคุณ",
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
              ),
              Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),
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
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  _callRead() async {
    var model = await postDio(server + 'currency/read', {'code': '1'});
    setState(() => priceUsd = model['bath']);
    var response =
        await postDio('${server}m/manageAddress/read', {'isDefault': true});
    if (response.length > 0) {
      var defaultAddress = response[0];
      setState(() => {
            hasAddress = true,
            name = defaultAddress['title'],
            phone = defaultAddress['phone'],
            address = {
              'code': defaultAddress['code'],
              'address': defaultAddress['address'],
              'subDistrict': defaultAddress['subDistrictTitle'],
              'district': defaultAddress['districtTitle'],
              'province': defaultAddress['provinceTitle'],
              'postalCode': defaultAddress['postalCode'].toString(),
            }
          });
    }
  }

  paymentCC() async {
    setState(() {
      loading = true;
    });
    String codes = '';
    dynamic order = widget.productList;
    var orderNo = uuid.v4();
    final profileCode = await storage.read(key: 'profileCode10');
    //set data.
    order.map((e) {
      if (codes == '') {
        codes = e['code'];
      } else {
        codes += ',' + e['code'];
      }
      e['paymentType'] = paymentMethod['type'];
      e['referenceAddress'] = address['code'];
      e['address'] = address['address'];
      e['subDistrict'] = address['subDistrict'];
      e['district'] = address['district'];
      e['province'] = address['province'];
      e['postalCode'] = address['postalCode'];
      e['orderNo'] = orderNo;
      e['consigneeName'] = name;
      e['consigneePhone'] = phone;
      e['status'] = "V";
      e['profileCode'] = profileCode;
    }).toList();
    // set price format omise :: ex --> 20.00 = 2000
    var priceStr = await convertSumPrice();

    // validate field.
    var validField = await _validField();
    if (order == null) validField = true;

    if (!validField) {
      // Verify that the user has a phone number.
      var statusOTP = await _callReadOTP(profileCode);
      if (statusOTP) {
        // success
        dynamic cartCreate;
        dynamic cartUpdate;
        dynamic charge;
        dynamic logCreate;
        //check order from 'buy now' or 'cart'.
        if (order.length == 1 && widget.from == 'buyNow') {
          cartCreate = await postDio(server + 'm/cart/create',
              {'orderNoReference': uuid.v4(), ...order[0]});
          codes = cartCreate['code'];
        }

        // create charge for payment.
        charge = await postOmise(endpoint_omise_m + 'charges', {
          'amount': priceStr,
          'currency': 'THB',
          'description': codes,
          // 'return_uri': return_uri_omise + codes + '/complete',
          'customer': paymentMethod['data']['customerID'],
          'card': paymentMethod['data']['cardID']
        });

        if (charge['object'] == 'error') {
          setState(() {
            loading = false;
          });
          return toastFail(context, text: 'เกิดข้อผิดพลาด');
        }

        if (charge['status'] != 'successful') {
          setState(() {
            loading = false;
          });
          return toastFail(context, text: charge['failure_message']);
        }

        //create log on database 'paymentLog'
        logCreate = await postDioAny(server + 'paymentLog/create', {
          'respProcess': '',
          'respMethod': 'CC',
          'paymentProvider': 'omise',
          'respTransaction': charge['id'],
          'respNumber': '', // respNumber จะถูกสร้างใน api
          'respAmount': priceStr,
          'respCurrency': 'THB',
          'respStatus': '1',
          'respURL': paymentMethod['data']['cardID'],
        });
        if (widget.from != 'buyNow') {
          dynamic update = await postDioList(server + 'm/cart/update', order);
        }
        // update order.
        cartUpdate = await postDio(server + 'm/cart/order/code/update', {
          'code': codes,
          'address': address['code'],
          'paymentType': 'CC',
          'paymentNumber': logCreate['objectData']['respNumber'],
        });

        if (cartUpdate != null) {
          await postDio(server + 'paymentlog/read',
              {'code': logCreate['objectData']['respNumber']});
          Navigator.push(
            context,
            scaleTransitionNav(PaymentCreditSuccess()),
          );
        } else {
          setState(() {
            loading = false;
          });
          toastFail(context);
        }
      }
    } else {
      setState(() {
        loading = false;
      });
      toastFail(
        context,
        text: 'กรุณาเพิ่มที่อยู่',
        color: Colors.white,
        fontColor: Colors.red,
      );
    }
  }

  paymentTQ() async {
    setState(() {
      loading = true;
    });
    String codes = '';
    List<dynamic> order = widget.productList;
    var orderNo = uuid.v4();
    final profileCode = await storage.read(key: 'profileCode10');
    order.map((e) {
      if (codes == '') {
        codes = e['code'];
      } else {
        codes += ',' + e['code'];
      }
      e['paymentType'] = paymentMethod['type'];
      e['referenceAddress'] = address['code'];
      e['address'] = address['address'];
      e['subDistrict'] = address['subDistrict'];
      e['district'] = address['district'];
      e['province'] = address['province'];
      e['postalCode'] = address['postalCode'];
      e['orderNo'] = orderNo;
      e['consigneeName'] = name;
      e['consigneePhone'] = phone;
      e['status'] = "V";
      e['profileCode'] = profileCode;
    }).toList();

    var validField = await _validField();
    if (order == null) validField = true;

    if (!validField) {
      var statusOTP = await _callReadOTP(profileCode);
      if (statusOTP) {
        omise(order, codes);
        // webpak(order, codes);
      }
    } else {
      setState(() {
        loading = false;
      });
      toastFail(
        context,
        text: 'กรุณาเพิ่มที่อยู่',
        color: Colors.white,
        fontColor: Colors.red,
      );
    }
  }

  webpak(List<dynamic> order, String codes) async {
    dynamic logCreate;
    dynamic cartCreate;
    dynamic cartUpdate;
    dynamic webpakRes;
    //check order from 'buy now' or 'cart'.
    if (order.length == 1 && widget.from == 'buyNow') {
      cartCreate = await postDio(server + 'm/cart/create',
          {'orderNoReference': uuid.v4(), ...order[0]});
      codes = cartCreate['code'];
    }

    webpakRes = await postPayment(codes.toString(), '0.27');
    logCreate = await postDioAny(server + 'paymentLog/create', {
      'respProcess': webpakRes['resCode'].toString(),
      'respMethod': webpakRes['resMethod'].toString(),
      'respTransaction': webpakRes['resOrder'].toString(),
      'respNumber': webpakRes['resNumber'].toString(),
      'respAmount': webpakRes['resAmount'].toString(),
      'respCurrency': webpakRes['resCurrency'].toString(),
      'respStatus': webpakRes['resStatus'].toString(),
      'respMessage': webpakRes['resMsg'].toString(),
      'respURL': webpakRes['resImg'].toString(),
    });
    if (widget.from != 'buyNow') {
      dynamic update = await postDioList(server + 'm/cart/update', order);
    }
    cartUpdate = await postDio(server + 'm/cart/order/code/update', {
      'code': codes.toString(),
      'address': address['code'],
      'paymentType': 'TQ',
      'paymentNumber': logCreate['objectData']['respNumber'],
    });

    if (cartUpdate != null) {
      Navigator.push(
        context,
        scaleTransitionNav(
          QRPayment(
            code: logCreate['objectData']['respNumber'],
            back: false,
          ),
        ),
      );
    } else {
      setState(() {
        loading = false;
      });
      toastFail(context);
    }
  }

  omise(dynamic order, String codes) async {
    dynamic cartCreate;
    dynamic cartUpdate;
    dynamic charge;
    dynamic getQr;
    dynamic logCreate;
    if (order.length == 1 && widget.from == 'buyNow') {
      cartCreate = await postDio(server + 'm/cart/create',
          {'orderNoReference': uuid.v4(), ...order[0]});
      codes = cartCreate['code'];
    }

    // 'source[type]': 'promptpay',
    var priceStr = await convertSumPrice();
    dynamic model = {
      'source[type]': 'promptpay',
      'amount': priceStr,
      'currency': 'THB',
      'description': codes
    };
    // dynamic obj = {"type": "promptpay"};

    // model['source'] = obj;

    charge = await postOmise(endpoint_omise_m + 'charges', model);
    if (charge['object'] == 'error') {
      setState(() {
        loading = false;
      });
      return toastFail(context, text: 'something wrong here.');
    }
    // print(charge['source']['scannable_code']['image']);
    // print(charge['source']['scannable_code']['image']['download_uri']);
    getQr = await postDioAny(server + 'cart/omise/charges', {
      'linkUrl': charge['source']['scannable_code']['image']['download_uri'],
      'title': charge['source']['scannable_code']['image']['filename'],
    });

    // print(' 000  ${getQr}');

    logCreate = await postDioAny(server + 'paymentLog/create', {
      'respProcess': '',
      'respMethod': 'TQ',
      'paymentProvider': 'omise',
      'respTransaction': charge['id'],
      'respNumber': '', // respNumber จะถูกสร้างใน api
      'respAmount': priceStr,
      'respCurrency': charge['currency'],
      'respStatus': '1',
      'respURL': getQr['message'],
    });
    if (widget.from != 'buyNow') {
      dynamic update = await postDioList(server + 'm/cart/update', order);
    }
    cartUpdate = await postDio(server + 'm/cart/order/code/update', {
      'code': codes,
      'address': address['code'],
      'paymentType': 'TQ',
      'paymentNumber': logCreate['objectData']['respNumber'],
    });
    if (cartUpdate != null) {
      Navigator.push(
        context,
        scaleTransitionNav(
          QRPayment(
            code: logCreate['objectData']['respNumber'],
            back: false,
          ),
        ),
      );
    } else {
      setState(() {
        loading = false;
      });
      toastFail(context);
    }

    setState(() {
      loading = false;
    });
  }

  Future<bool> _callReadOTP(profileCode) async {
    var status = false;
    var profileCategory = await storage.read(key: 'profileCategory');

    var response = await postDio(server + "m/v2/register/read",
        {"category": profileCategory, 'code': profileCode});

    if (response == null) return false;

    if (response['phone'] == null ||
        response['phone'] == '' && response['code'] == profileCode) {
      await Navigator.push(
        context,
        scaleTransitionNav(
          OTPLoginPage(userData: response),
        ),
      ).then((value) => {if (value != null) status = value});
    } else {
      status = true;
    }

    return status;
  }

  getOrderNo(order) async {
    var newMap = groupBy(
        order,
        (obj) =>
            obj['referenceShopCode'] != null ? obj['referenceShopCode'] : '');

    var shopList = [];
    var keyList = [];
    keyList = newMap.keys.toList();
    var orderNoResponse = await dio.get(
        'http://core148.we-builds.com/payment-api/WeMart/Create/' +
            newMap.length.toString());

    if (orderNoResponse.data['status'] == 'S') {
      for (int i = 0; i < keyList.length; i++) {
        shopList.add({
          'referenceShopCode': keyList[i],
          'orderNo': orderNoResponse.data['objectData']['items'][i],
          'orderNoReference': orderNoResponse.data['objectData']['code'],
        });
      }

      await order.map((e) {
        var item = shopList.firstWhere(
            (s) => s['referenceShopCode'] == e['referenceShopCode']);
        e['orderNo'] = item['orderNo'];
        e['orderNoReference'] = item['orderNoReference'];
      }).toList();

      return order;
    } else {
      toastFail(context);
      return null;
    }
  }

  _validField() {
    var status = true;
    if (address['code'] != '' && address['code'] != null) status = false;
    return status;
  }

  convertSumPrice() {
    var split = sumPrice.toString().split('.');
    if (split[1].length == 1) {
      return split[0] + split[1] + '0';
    } else {
      return split[0] + split[1];
    }
  }

  totalPriceUsd(param) {
    if (param < 0.01) return '';

    var usd = param / priceUsd;
    return priceFormat.format(usd) + " usd";
  }
}
