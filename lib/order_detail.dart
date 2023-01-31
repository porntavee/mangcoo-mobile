import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/form_content_shop.dart';
import 'package:wereward/login.dart';
import 'package:wereward/process_of_delivery.dart';
import 'package:wereward/qr_payment.dart';
import 'package:wereward/review_page.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

import 'chat.dart';
import 'return_form.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({Key key, @required this.model}) : super(key: key);

  final dynamic model;

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  dynamic model = {};
  String profileCode = '';
  String val = '';
  bool isval = false;
  final storage = new FlutterSecureStorage();
  Future<dynamic> _futureProfile;
  Future<dynamic> _futureVerify;
  Future<dynamic> _futureOrganizationImage;
  @override
  void initState() {
    _read();
    model = widget.model;
    // print(model[0]['items'][0]['orderNo']);
    // print(model[0]['items'][0]['orderNoReference']);
    // print(model[0]['items'][0]['paymentNumber']);
    // print(model['']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header2(context, title: 'รายละเอียดคำสั่งซื้อ'),
      body: Stack(
        children: [
          ListView(
            children: [
              statusText(model[0]['items'][0]['status']),
              SizedBox(height: 8),
              _buildAddress(model[0]['items'][0]),
              SizedBox(height: 8),
              ...model
                  .map<Widget>(
                    (listItemsShop) => Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listItemsShop['shopName'],
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                          ...listItemsShop['items']
                              .map<Widget>((e) => _buildBodyItem(e))
                              .toList(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รวมราคา',
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                priceFormat.format(listItemsShop['total']),
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.red[700],
                                  fontSize: 17,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
                width: double.infinity,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'คำสั่งซื้อ',
                            // 'หมายเลขคำสั่งซื้อ',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          model[0]['items'][0]['orderNoReference'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 13,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' คัดลอก',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 14,
                            color: Colors.greenAccent[700],
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        scaleTransitionNav(
                          ChatPage(
                            referenceShopCode: model[0]['shopCode'],
                            profileCode: profileCode,
                            isProfileSend: true,
                            callByProfile: true,
                          ),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: (MediaQuery.of(context).size.width / 100) *
                            90, //150,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.redAccent, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/letter.png',
                              height: 15,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text("ติดต่อผู้ขาย"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (model[0]['items'][0]['status'] == 'A')
                Container(
                  padding: EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 100),
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          scaleTransitionNav(
                            ReviewPage(
                              model: model,
                            ),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          width: (MediaQuery.of(context).size.width / 100) *
                              90, //150,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(color: Colors.redAccent, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("รีวิว"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          boxBottomBar(bottomStatus()),
        ],
      ),
    );
  }

  _read() async {
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
  }

  Container _buildAddress(address) {
    String textAddress = address['consigneeName'] +
        '\n' +
        address['consigneePhone'] +
        '\n' +
        address['address'] +
        ' ' +
        address['subDistrict'] +
        ' ' +
        address['district'] +
        ' ' +
        address['province'] +
        ' ' +
        address['postalCode'];
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ที่อยู่ในการจัดส่ง',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'คัดลอก',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 16,
                  color: Colors.greenAccent[700],
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Text(
            textAddress,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
              color: Colors.grey[800],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBodyItem(model) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Hero(
            tag: model['code'],
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey[400])),
              child: loadingImageNetwork(
                model['imageUrl'],
                height: 130,
                width: 130,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 130,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    model['goodsTitle'],
                    style: TextStyle(
                      color: Color(0xFF0000000),
                      fontFamily: 'Kanit',
                      fontSize: 13,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Expanded(
                    child: Text(
                      model['title'].toString(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: 'Kanit',
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (model['price'] != model['netPrice'])
                        Text(
                          priceFormat.format(model['price'] * model['qty']),
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontFamily: 'Kanit',
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        priceFormat.format(model['netPrice'] * model['qty']),
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontFamily: 'Kanit',
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '  x ' + model['qty'].toString(),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontFamily: 'Kanit',
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget boxBottomBar(Widget child) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80 + MediaQuery.of(context).padding.bottom,
        width: double.infinity,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(width: 1, color: Colors.grey))),
        child: child,
      ),
    );
  }

  Widget bottomStatus() {
    if (model[0]['items'][0]['status'] == 'V')
      return StackTap(
        onTap: () => {
          Navigator.push(
            context,
            fadeNav(
              QRPayment(code: model[0]['items'][0]['paymentNumber']),
            ),
          ).then(
            (value) => Navigator.pop(context),
          ),
        },
        child: Container(
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width / 100) * 90, //150,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ชำระเงิน',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    else if (model[0]['items'][0]['status'] == 'W')
      return StackTap(
        onTap: () => {
          buildModal('cart'),
        },
        child: Container(
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width / 100) * 90, //150,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ยกเลิกคำสั่งซื้อ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    if (model[0]['items'][0]['status'] == 'P')
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StackTap(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReturnFormPage(model: model),
              ),
            ).then(
              (value) => {if (value) Navigator.pop(context)},
            ),
            child: Container(
              alignment: Alignment.center,
              width: (MediaQuery.of(context).size.width / 100) * 45, //150,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Text(
                'ขอคืนเงิน/คืนสินค้า',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          StackTap(
            onTap: () =>
                updateStatus(model[0]['items'][0]['orderNoReference'], 'A'),
            child: Container(
              alignment: Alignment.center,
              width: (MediaQuery.of(context).size.width / 100) * 45, //150,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'ฉันได้ตรวจสอบและยอมรับสินค้า',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    else if (model[0]['items'][0]['status'] == 'A')
      return StackTap(
        onTap: () => Navigator.push(
          context,
          fadeNav(FormContentShop(
            model: {'code': model['goodsCode'], 'imageUrl': model['imageUrl']},
          )),
        ),
        child: Container(
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width / 100) * 90, //150,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ส่งอีกครั้ง',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    else
      return Container();
  }

  Widget statusText(
    String status,
  ) {
    String text = '';
    Color color = Color(0xFF10BC37);
    switch (status) {
      case "A":
        text = 'เสร็จสิ้น';
        color = Color(0xFF10BC37);
        break;
      case "P":
        text = 'อยู่ระหว่างการจัดส่ง';
        color = Color(0xFFE69700);
        break;
      case "V":
        text = 'รอชำระเงิน';
        color = Color(0xFFE69700);
        break;
      case "W":
        text = 'รอการจัดส่ง';
        color = Color(0xFFE69700);
        break;
      case "R":
        text = 'ยกเลิก';
        color = Color(0xFFED5643);
        break;
      default:
        text = '';
        color = Colors.grey;
    }

    return InkWell(
      onTap: () async {
        if (model[0]['items'][0]['status'] == 'A' ||
            model[0]['items'][0]['status'] == 'W' ||
            model[0]['items'][0]['status'] == 'P') {
          // if (profileCode != '' && profileCode != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  ProcessOfDeliveryPage(model: model),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: CupertinoAlertDialog(
                  title: new Text(
                    'ไม่สามารถดูขั้นตอนการจัดส่งได้',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  content: Text(" "),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: new Text(
                        "ตกลง",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Kanit',
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontFamily: 'Kanit',
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  buildModal(String type) {
    return showCupertinoModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Material(
              type: MaterialType.transparency,
              child: new Container(
                height: MediaQuery.of(context).size.height * 0.60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Stack(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'ยกเลิกคำสั่งซื้อ',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          color: Color(0XFFFFF8DC),
                          child: Text(
                            'กรุณาเลือกเหตุผลที่คุณต้องการยกเลิกคำสั่งซื้อ คำสั่งซื้อจะถูกยกเลิกทันทีที่คุณยืนยันเหตุผลในการยกเลิก',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(
                            () {
                              val = "ต้องการเปลี่ยนที่อยู่ในการจัดส่ง";
                            },
                          ),
                          child: ListTile(
                            title: Text("ต้องการเปลี่ยนที่อยู่ในการจัดส่ง"),
                            leading: Radio(
                              value: "ต้องการเปลี่ยนที่อยู่ในการจัดส่ง",
                              groupValue: val,
                              onChanged: (value) {
                                setState(() {
                                  val = value;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(
                            () {
                              val = "ผู้ชายไม่ตอบสนองการสอบถามข้อมูล";
                            },
                          ),
                          child: ListTile(
                            title: Text("ผู้ชายไม่ตอบสนองการสอบถามข้อมูล"),
                            leading: Radio(
                              value: "ผู้ชายไม่ตอบสนองการสอบถามข้อมูล",
                              groupValue: val,
                              onChanged: (value) {
                                setState(() {
                                  val = value;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(
                            () {
                              val = "อื่นๆหรือเปลี่ยนใจ";
                            },
                          ),
                          child: ListTile(
                            title: Text("อื่นๆหรือเปลี่ยนใจ"),
                            leading: Radio(
                              value: "อื่นๆหรือเปลี่ยนใจ",
                              groupValue: val,
                              onChanged: (value) {
                                setState(() {
                                  val = value;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                        ),
                        isval
                            ? Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(5),
                                color: Color(0XFFFF4500),
                                child: Text(
                                  'กรุณาเลือกเหตุผล',
                                  style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).accentColor,
                          ),
                          child: Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      left: 10,
                      child: InkWell(
                        onTap: () => {
                          if (val == '')
                            setState(() {
                              isval = true;
                            })
                          else
                            {
                              updateStatusCancel(
                                model[0]['items'][0]['orderNoReference'],
                                'R',
                                true,
                                val,
                              ),
                              Navigator.pop(context)
                            }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: (MediaQuery.of(context).size.width / 100) *
                              90, //150,
                          height: 50,
                          decoration: BoxDecoration(
                            // color: Color(0xFFFFFFFF),
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Text(
                            'ยกเลิกคำสั่งซื้อ',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  updateStatus(item, status) async {
    await postDio('${server}m/cart/order/status/update', {
      'code': item,
      'status': status,
    });
    Navigator.pop(context);
  }

  updateStatusCancel(item, status, bool cancel, String reason) async {
    await postDio('${server}m/cart/order/status/update', {
      'code': item,
      'status': status,
      'isCancel': cancel,
      'reason': reason,
    });
    Navigator.pop(context);
  }
}
