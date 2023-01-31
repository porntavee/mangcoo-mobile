import 'package:flutter/material.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:wereward/confirm_order.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';

class CartButtonConfirm extends StatefulWidget {
  CartButtonConfirm({Key key, this.model, this.checkAll}) : super(key: key);

  final dynamic model;
  final Function(bool) checkAll;
  @override
  _CartButtonConfirmState createState() => _CartButtonConfirmState();
}

class _CartButtonConfirmState extends State<CartButtonConfirm> {
  List<dynamic> selectedList = new List<dynamic>();
  bool selectedAll = false;
  double totalPrice = 0.0;
  double priceUsd = 0.0;

  @override
  void initState() {
    super.initState();
    read();
  }

  read() async {
    var model = await postDio(server + 'currency/read', {'code': '1'});
    setState(() => priceUsd = model['bath']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 70 + MediaQuery.of(context).padding.bottom,
        width: double.infinity,
        color: Color(0xFFE84C10),
        child: Column(
          children: [
            FutureBuilder(
                future: setData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => {},
                              child: Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                width: 300,
                                alignment: Alignment.center,
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildCheckItem(selectedAll),
                                        SizedBox(width: 15),
                                        Text(
                                          'ทั้งหมด',
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontFamily: 'Kanit',
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'รวมทั้งหมด',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Kanit',
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${priceFormat.format(snapshot.data['totalPrice']) + " บาท"}',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Kanit',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                totalPriceUsd(snapshot
                                                    .data['totalPrice']),
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Kanit',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              selectedList = [];
                              bool waitForIt = false;
                              widget.model.forEach(
                                (e) => e['items'].forEach(
                                  (o) => {
                                    if (o['qty'] > o['inventoryQty'] &&
                                        o['selected'])
                                      waitForIt = true,
                                    o['referenceShopCode'] = e['code'][1],
                                    if (o['selected']) selectedList.add(o)
                                  },
                                ),
                              );
                              if (selectedList.length > 0 && !waitForIt)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConfirmOrderPage(
                                      productList: selectedList,
                                    ),
                                  ),
                                );
                              else
                                toastFail(
                                  context,
                                  text: waitForIt
                                      ? 'ขออภัยสินค้ามีจำนวนไม่พอ'
                                      : 'กรุณาเลือกสินค้า',
                                  color: Colors.white,
                                  fontColor: Colors.red,
                                );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'ชำระเงิน',
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: LoadingTween(
                        height: 60,
                      ),
                    );
                  }
                }),
            Expanded(
              child: Container(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InkWell buildCheckItem(check) {
    return InkWell(
      onTap: () => widget.checkAll(selectedAll),
      child: Container(
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            width: 1,
            color: check ? Color(0xFFE84C10) : Colors.grey,
          ),
          color: check ? Color(0xFFE84C10) : Colors.white,
        ),
        child: check
            ? Icon(
                Icons.check_rounded,
                size: 20,
                color: Colors.white,
              )
            : Container(),
      ),
    );
  }

  setData() async {
    bool someShopSlected = true;
    totalPrice = 0.0;
    widget.model.forEach(
      (element) {
        element['items'].forEach(
          (c) => {
            if (!c['selected'])
              {
                if (c['inventoryQty'] > 0) {someShopSlected = false}
              }
            else
              totalPrice = totalPrice + (c['netPrice'] * c['qty'])
          },
        );
      },
    );
    setState(() {
      selectedAll = someShopSlected;
    });

    return {'selectedAll': someShopSlected, 'totalPrice': totalPrice};
  }

  totalPriceUsd(param) {
    if (param < 0.01) return '';

    var usd = param / priceUsd;
    return priceFormat.format(usd) + " usd";
  }
}
