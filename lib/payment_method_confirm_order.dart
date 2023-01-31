import 'package:flutter/material.dart';
import 'package:wereward/my_credit_card_add.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class PaymentMethodConfirmOrder extends StatefulWidget {
  const PaymentMethodConfirmOrder({Key key, this.method}) : super(key: key);

  final dynamic method;

  @override
  _PaymentMethodConfirmOrderState createState() =>
      _PaymentMethodConfirmOrderState();
}

class _PaymentMethodConfirmOrderState extends State<PaymentMethodConfirmOrder> {
  dynamic selectedMethod = {'type': '', 'data': ''};
  bool _openCredit = false;
  bool _openCounter = false;
  bool _openMobile = false;
  List<dynamic> listCredit = [];

  @override
  void initState() {
    if (widget.method != null) selectedMethod = widget.method;
    callRead();
    super.initState();
  }

  callRead() async {
    listCredit = await postDio('${server}m/manageCreditCard/read', {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header2(context, title: 'วิธีการชำระเงิน'),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          buildListBody(),
          buildConfirmBody(),
        ],
      ),
    );
  }

  Widget buildListBody() {
    return ListView(
      children: [
        // buildCashOnDelivery(),
        buildSelect(
            title: 'Thai QR',
            callback: () => {
                  setState(() => selectedMethod = {
                        'type': 'TQ',
                        'title': 'Thai QR',
                        'data': ''
                      })
                }),
        buildDropDown(
            title: 'บัตรเครดิต/บัตรเดบิต',
            action: _openCredit,
            model: listCredit,
            callback: () => {
                  setState(() => _openCredit = !_openCredit),
                }),
        // buildDropDown(
        //     title: 'เคาท์เตอร์เซอวิส (ยังไม่เปิดให้บริการ)',
        //     // action: _openCounter,
        //     model: [],
        //     callback: () => {
        //           // setState(() => _openCounter = !_openCounter),
        //         }),
        // buildDropDown(
        //     title: 'Mobile Banking (ยังไม่เปิดให้บริการ)',
        //     // action: _openMobile,
        //     model: [],
        //     callback: () => {
        //           // setState(() => _openMobile = !_openMobile),
        //         }),

        SizedBox(height: 50)
      ],
    );
  }

  Widget buildCashOnDelivery() {
    return StackTap(
      splashColor: Colors.black.withOpacity(0.3),
      onTap: () => toastFail(context, text: '(ยังไม่เปิดให้บริการ)'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFc5c5c5), width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เก็บเงินปลายทาง',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
              ),
            ),
            Text(
              'Cash on Delivery',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSelect({String title, Function callback}) {
    return StackTap(
      splashColor: Colors.black.withOpacity(0.3),
      onTap: () {
        callback();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFc5c5c5), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
              ),
            ),
            if (selectedMethod['title'] == title)
              Icon(
                Icons.check_circle_outline_rounded,
                size: 20,
                color: Color(0xFFED5643),
              )
          ],
        ),
      ),
    );
  }

  Widget buildDropDown(
      {String title,
      bool action = false,
      List<dynamic> model,
      Function callback}) {
    return Column(
      children: [
        StackTap(
          splashColor: Colors.black.withOpacity(0.05),
          onTap: () {
            callback();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14,
                  ),
                ),
                Icon(
                  action
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                )
              ],
            ),
          ),
        ),
        if (action)
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Column(
              children: [
                ...model
                    .map<Widget>(
                      (e) => InkWell(
                        onTap: () {
                          setState(() {
                            selectedMethod = {
                              'type': 'CC',
                              'title': 'บัตรเครดิต',
                              'data': {
                                'cardID': e['cardID'],
                                'tokenID': e['tokenID'],
                                'customerID': e['customerID'],
                              }
                            };
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 50,
                              alignment: Alignment.centerLeft,
                              child: Text('บัตรเครดิต *${e['number']}'),
                            ),
                            if (selectedMethod['type'] == 'CC')
                              if (selectedMethod['data']['cardID'] ==
                                  e['cardID'])
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 20,
                                    color: Color(0xFFED5643),
                                  ),
                                )
                          ],
                        ),
                      ),
                    )
                    .toList(),
                InkWell(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyCreditCardAddPage(),
                      ),
                    ).then((value) =>
                        {callRead(), setState(() => _openCredit = false)}),
                  },
                  child: Container(
                    height: 40,
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 10),
                        Text('เพิ่มบัตรเครดิต'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          height: 0.5,
          color: Color(0xFFc5c5c5),
        )
      ],
    );
  }

  Widget buildConfirmBody() {
    return Positioned(
      bottom: 0 + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Container(
        height: 50,
        width: double.infinity,
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFc5c5c), width: 1),
          ),
        ),
        child: StackTap(
          onTap: () => selectedMethod['type'] != ''
              ? Navigator.pop(context, selectedMethod)
              : {},
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color:
                  selectedMethod['type'] != '' ? Colors.red : Color(0xFFc5c5c5),
            ),
            child: Text(
              'ยืนยัน',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
