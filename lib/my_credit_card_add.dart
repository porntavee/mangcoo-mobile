import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/credit_card_form_field.dart';
import 'package:wereward/component/expiration_form_field.dart';
import 'package:wereward/component/loading_page.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_payment.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'widget/header.dart';

class MyCreditCardAddPage extends StatefulWidget {
  MyCreditCardAddPage({Key key, this.code: ''}) : super(key: key);

  final String code;
  @override
  _MyCreditCardAddPageState createState() => _MyCreditCardAddPageState();
}

class _MyCreditCardAddPageState extends State<MyCreditCardAddPage> {
  List<dynamic> model;
  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController expirationController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  bool isActive = false;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  var tempData = List<dynamic>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var _paymentCard = PaymentCard();
  var _autoValidateMode = AutovalidateMode.disabled;

  var _card = new PaymentCard();
  bool loading = false;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    if (widget.code != '') _callRead();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    titleController.dispose();
    expirationController.dispose();
    cvvController.dispose();
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
          title: 'จัดการบัตรเครดิต',
        ),
        backgroundColor: Colors.white,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: loading
              ? LoadingPage()
              : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  children: _buildList(),
                ),
        ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(height: 10),
      // Text(
      //   'บัตรที่รองรับ',
      //   style: TextStyle(
      //     fontFamily: 'Kanit',
      //     fontSize: 15,
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      // SizedBox(height: 10),
      // Wrap(
      //   spacing: 10,
      //   runSpacing: 10,
      //   children: ['visa', 'masterCard', 'Paypal']
      //       .map(
      //         (e) => Container(
      //           height: 30,
      //           width: 80,
      //           alignment: Alignment.center,
      //           decoration: BoxDecoration(
      //               borderRadius: BorderRadius.circular(5),
      //               border: Border.all(
      //                 width: 1,
      //                 color: Colors.grey,
      //               )),
      //           child: Text(
      //             e,
      //             style: TextStyle(
      //               fontFamily: 'Kanit',
      //               fontSize: 15,
      //               color: Colors.grey,
      //             ),
      //           ),
      //         ),
      //       )
      //       .toList(),
      // ),
      // SizedBox(height: 10),
      // Text(
      //   'บัตรที่รองรับ',
      //   style: TextStyle(
      //     fontFamily: 'Kanit',
      //     fontSize: 15,
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      Padding(
        padding: EdgeInsets.only(left: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('บันทึกข้อมูลบัตร',
                style: TextStyle(fontFamily: 'Kanit', fontSize: 15)),
            Switch(
              value: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = !isActive;
                });
              },
              activeTrackColor: Theme.of(context).accentColor,
              activeColor: Color(0xFFFFFFFF),
            )
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "ชื่อ-สกุล ผู้ถือบัตร",
                  hintText: "ชื่อ-สกุล ผู้ถือบัตร",
                ),
                onSaved: (String value) {},
              ),
              SizedBox(height: 10),
              new Stack(
                children: [
                  new TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(19),
                      new CardNumberInputFormatter()
                    ],
                    controller: numberController,
                    decoration: InputDecoration(
                      // icon: CardUtils.getCardIcon(_paymentCard.type),
                      border: OutlineInputBorder(),
                      labelText: "เลขบัตร",
                      hintText: "เลขบัตร",
                    ),
                    onSaved: (String value) {
                      if (value.isNotEmpty)
                        _paymentCard.number = CardUtils.getCleanedNumber(value);
                    },
                    onChanged: (String value) {
                      var a = _formKey.currentState.validate();
                      if (value.length >= 22)
                        FocusScope.of(context).nextFocus();
                    },
                    // validator: CardUtils.validateCardNum,
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      alignment: Alignment.center,
                      child: CardUtils.getCardIcon(_paymentCard.type),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              new TextFormField(
                controller: cvvController,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  new LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "CVV",
                  hintText: "CVV",
                ),
                // validator: CardUtils.validateCVV,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _paymentCard.cvv = int.parse(value);
                },
                onChanged: (String value) {
                  if (value.length >= 3) FocusScope.of(context).nextFocus();
                },
              ),
              SizedBox(height: 10),
              SizedBox(
                child: ExpirationFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "วันหมดอายุของบัตร (ดด/ปป)",
                    hintText: "ดด/ปป",
                    hintStyle: TextStyle(color: Color(0xFFc5c5c5)),
                  ),
                  controller: expirationController,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 40),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 45,
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(10.0),
            color: Color(0xFFED5643),
            child: MaterialButton(
              onPressed: () async {
                final form = _formKey.currentState;
                if (form.validate()) {
                  save();
                }
              },
              child: new Text(
                'ยืนยัน',
                style: new TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Kanit',
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 40),
    ];
  }

  save() async {
    setState(() => loading = true);
    dynamic response;
    dynamic resToken = {};
    dynamic resCustomer = {};
    String path = widget.code != '' ? 'update' : 'create';
    Map<String, dynamic> cardJson = {};
    Map<String, dynamic> customerJson = {};

    Map<String, String> token = {
      'card[name]': titleController.text,
      'card[number]': numberController.text,
      'card[security_code]': cvvController.text,
      'card[expiration_month]':
          int.tryParse(expirationController.text.substring(0, 2)).toString(),
      'card[expiration_year]': '20' +
          int.tryParse(expirationController.text.substring(3, 5)).toString()
    };

    final profileCode = await storage.read(key: 'profileCode10');
    final profileCategory = await storage.read(key: 'profileCategory');
    var user = await postDio(server + "m/v2/register/read",
        {"category": profileCategory, 'code': profileCode});
    String customerID = user['customerID'];

    // ?? step 1 create customer in omise server.
    resToken = await postOmise(endpoint_omise_v + 'tokens', token, pkey: true);

    if (customerID == '' || customerID == null || customerID == 'null') {
      resCustomer = await postOmise(endpoint_omise_m + 'customers', {
        'description': profileCode.toString(),
        'card': resToken['id'].toString()
      });

      await storage.write(
        key: 'customerID',
        value: resCustomer['id'].toString(),
      );

      customerID = resCustomer['id'].toString();
    }

    setState(() => loading = false);

    if (resToken['object'] == 'error') {
      setState(() => loading = false);
      return toastFail(context, text: resToken['message']);
    }

    cardJson = {
      'number': int.tryParse(numberController.text.substring(0, 4)).toString(),
      'tokenID': resToken['id'],
      'cardID': resToken['card']['id'],
      'customerID': customerID,
    };

    // ?? step 2 update our database.
    response = await postDio('${server}m/manageCreditCard/create', cardJson);
    setState(() => loading = false);
    if (response['status'] != 'E') {
      Navigator.pop(context, 'success');
    } else {
      return toastFail(context, text: 'เกิดข่้อผิดพลาด');
    }
  }

  _callRead() async {
    var model = await postDio('${server}m/manageCreditCard/read', {
      "code": widget.code,
    });

    var data = model[0];
    titleController.text = data['title'];
    cvvController.text = data['phone'];
    expirationController.text = data['address'];

    setState(() {
      isActive = data['isActive'];
    });
  }

  delete() async {
    await postDio('${server}m/manageCreditCard/delete', {
      "code": widget.code,
    }).then((value) {
      Navigator.pop(context);
      Navigator.pop(context, 'success');
    });
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
      _showInSnackBar('Payment card is valid');
    }
  }

  Widget _getPayButton() {
    if (Platform.isIOS) {
      return new CupertinoButton(
        onPressed: _validateInputs,
        color: CupertinoColors.activeBlue,
        child: const Text(
          Strings.pay,
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    } else {
      return new ElevatedButton(
        onPressed: _validateInputs,
        child: new Text(
          Strings.pay.toUpperCase(),
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    }
  }

  void _showInSnackBar(String value) {
    // ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
    //   content: new Text(value),
    //   duration: new Duration(seconds: 3),
    // ));
  }
}
