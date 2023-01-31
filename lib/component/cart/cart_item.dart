import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/cart/cart_button_confirm.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/component/material/form_content_shop.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/nav_animation.dart';

class CartItemPage extends StatefulWidget {
  CartItemPage({Key key, this.model, this.refresh, this.refreshController})
      : super(key: key);

  final dynamic model;
  final Function refresh;
  final RefreshController refreshController;
  @override
  _CartItemPageState createState() => _CartItemPageState();
}

class _CartItemPageState extends State<CartItemPage> {
  dynamic model;
  Future<dynamic> _futureModel;
  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    model = widget.model;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (model.length == 0)
      return buildEmptyCart();
    else
      return Stack(
        children: [
          _screen(),
          CartButtonConfirm(
            model: model,
            checkAll: (bool value) => checkAll(value),
          )
        ],
      );
  }

  _screen() {
    return ListView(
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.only(left: 15),
          color: Theme.of(context).backgroundColor,
          alignment: Alignment.centerLeft,
          child: Text(
            'สรุปคำสั่งซื้อทั้งหมด',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 15,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildListView(),
        SizedBox(height: 40),
      ],
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: model.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: setData(),
          builder: (context, snapshot) => Container(
            color: Color(0xFFFFFFFF),
            child: Column(
              children: [
                SizedBox(height: 15),
                buildShopName(model, index),
                ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  separatorBuilder: (context, index) => buildSpaceGrey(),
                  itemCount: model[index]['items'].length,
                  itemBuilder: (context, indexItem) => Slidable(
                    key: ValueKey(indexItem),
                    endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: ScrollMotion(),
                      children: [
                        Container(),
                        SlidableAction(
                          flex: 1,
                          onPressed: (context) =>
                              deleteItem(context, index, indexItem),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_forever_rounded,
                          label: 'ลบ',
                        ),
                      ],
                    ),
                    child: buildItem(
                        model[index]['items'][indexItem], index, indexItem),
                  ),
                ),
                buildSpaceGrey(height: 15)
              ],
            ),
          ),
        );
      },
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
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: widget.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  Container buildSpaceGrey({double height = 5.0}) {
    return Container(
      height: height,
      width: double.infinity,
      color: Theme.of(context).backgroundColor,
    );
  }

  buildItem(item, int index, int indexShop) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            scaleTransitionNav(
              FormContentShop(
                model: {
                  'code': item['goods'],
                  'price': item['price'],
                  'netPrice': item['netPrice'],
                  'description': '',
                  'rating': 5.0,
                  'imageUrl': item['imageUrl'],
                  'title': item['goodsTitle'],
                  'referenceShopName': item['referenceShopName'],
                  'like': false,
                },
                navFrom: 'cart',
              ),
            ),
          ).then((value) => _onRefresh()),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                InkWell(
                  onTap: () async =>
                      await checkItem(item, index), // index ร้่านค้า
                  child: buildCheckItem(item['selected']),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: loadingImageNetwork(item['imageUrl'],
                                height: 100, width: 100),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item['goodsTitle']}',
                                      style: TextStyle(
                                        color: Color(0xFF0000000),
                                        fontFamily: 'Kanit',
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (item['price'] != item['netPrice'])
                                        Text(
                                          '${priceFormat.format(item['price']) + " บาท"}',
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontFamily: 'Kanit',
                                            fontSize: 15,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${priceFormat.format(item['netPrice']) + " บาท"}',
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontFamily: 'Kanit',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // Text(
                                      //   '${priceFormat.format(item['priceUsd']) + " usd"}',
                                      //   style: TextStyle(
                                      //     color: Color(0xFF707070),
                                      //     fontFamily: 'Kanit',
                                      //     fontSize: 13,
                                      //     decoration:
                                      //         TextDecoration.lineThrough,
                                      //   ),
                                      // ),
                                      //      Text(
                                      //       '${priceFormat.format(item['netPriceUsd']) + " usd"}',
                                      //       style: TextStyle(
                                      //         color: Color(0xFF707070),
                                      //         fontFamily: 'Kanit',
                                      //         fontSize: 13,
                                      //       ),
                                      //     ),
                                      if (item['price'] != item['netPrice'])
                                        Text(
                                          '${priceFormat.format(item['priceUsd']) + " usd"}',
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontFamily: 'Kanit',
                                            fontSize: 13,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      SizedBox(width: 8),
                                      if (item['netPriceUsd'] != null)
                                        if (item['price'] != item['priceUsd'])
                                          Text(
                                            '${priceFormat.format(item['netPriceUsd']) + " usd"}',
                                            style: TextStyle(
                                              color: Color(0xFF707070),
                                              fontFamily: 'Kanit',
                                              fontSize: 13,
                                            ),
                                          ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          // margin: EdgeInsets.only(right: 7, left: 8),
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFFFFF),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Color(0xFF707070),
                                                width: 1),
                                          ),
                                          child: Text(
                                            '${item['title']}',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontFamily: 'Kanit',
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: 40,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'จำนวนสินค้า',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      buildCounterItem(
                        item['qty'],
                        item['inventoryQty'],
                        enCounter: () => setState(
                          () {
                            if (item['qty'] == 1) {
                              _buildDialog(index, indexShop);
                            }

                            if (item['qty'] > item['inventoryQty'])
                              item['qty'] = item['inventoryQty'];

                            if (item['qty'] > 1) item['qty']--;
                            widget;
                            postDio(server + 'm/cart/update/qty',
                                {'code': item['code'], 'qty': item['qty']});
                          },
                        ),
                        counter: () => setState(
                          () {
                            if (item['qty'] < item['inventoryQty'])
                              item['qty']++;
                            widget;
                            postDio(server + 'm/cart/update/qty',
                                {'code': item['code'], 'qty': item['qty']});
                          },
                        ),
                      ),
                      if (item['qty'] > item['inventoryQty'] &&
                          item['inventoryQty'] > 0) ...<Widget>[
                        SizedBox(height: 10),
                        Text(
                          'ขออภัย คุณสามารถซื้อสินค้านี้ได้เพียง ${item['inventoryQty']} ชิ้น เท่านั้น',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (item['inventoryQty'] <= 0)
          Positioned.fill(
              child: Container(
            color: Colors.grey.withOpacity(0.8),
            child: Center(
              child: Text(
                'สินค้าหมด',
                style: TextStyle(
                    fontFamily: 'Kanit', fontSize: 40, color: Colors.white),
              ),
            ),
          ))
      ],
    );
  }

  Container buildCheckItem(check) {
    return Container(
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
    );
  }

  Container buildShopName(shop, int index) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              setState(() => {
                    // if (notFoundItem != -1)
                    shop[index]['selected'] = !shop[index]['selected'],
                    shop[index]['items'] = shop[index]['items'].map((e) {
                      if (e['inventoryQty'] > 0)
                        e['selected'] = shop[index]['selected'];
                      return e;
                    }).toList(),
                  });
            },
            child: buildCheckItem(shop[index]['selected']),
          ),
          SizedBox(width: 15),
          Container(
            constraints: BoxConstraints(
              maxWidth: 300,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 20,
            child: Text(
              '${shop[index]['code'][0]}',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontFamily: 'Kanit',
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  buildCounterItem(
    int productQuantity,
    int maxProduct, {
    Function enCounter,
    Function counter,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => enCounter(),
          child: Container(
            height: 30,
            width: 50,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 1,
                color: Colors.black,
              ),
              color: Colors.white,
            ),
            child: Text(
              '-',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
                // color: productQuantity == 1 ? Colors.grey : Colors.black,
                color: Colors.black,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30,
            constraints: BoxConstraints(minWidth: 220),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1),
              color: Colors.white,
            ),
            child: Text(
              productQuantity.toString(),
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SizedBox(width: 5),
        InkWell(
          onTap: () => counter(),
          child: Container(
            height: 30,
            width: 50,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 1,
                color:
                    maxProduct == productQuantity ? Colors.grey : Colors.black,
              ),
              color: Colors.white,
            ),
            child: Text(
              '+',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
                color:
                    maxProduct == productQuantity ? Colors.grey : Colors.black,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }

  buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'รถเข็นยังว่างอยู่ ต้องหาอะไรมาเพิ่มหน่อยแล้ว!',
            style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
          ),
          SizedBox(height: 15),
          Image.asset('assets/images/cart.png', height: 80, width: 80),
          SizedBox(height: 15),
          InkWell(
            onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeMartPage()),
                (route) => false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  width: 1,
                  color: Color(0xFFED5643),
                ),
              ),
              child: Text(
                'ช้อปตอนนี้',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  color: Color(0xFFED5643),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildDialog(index, itemIndex) async {
    return await showDialog(
      barrierColor: Colors.black.withOpacity(0.3),
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        return CustomAlertDialog1(
            contentPadding: EdgeInsets.all(20),
            content: Container(
              height: 80,
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ลบสินค้า ?',
                    style: TextStyle(
                        fontFamily: 'Kanit', fontSize: 15, color: Colors.grey),
                  ),
                  Container(
                      height: 1, width: double.infinity, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              'ไม่',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(height: 40, width: 1, color: Colors.grey),
                      Expanded(
                        child: InkWell(
                          onTap: () => {
                            deleteItem(context, index, itemIndex),
                            Navigator.pop(context)
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            child: Text(
                              'ใช่',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
      },
    ).then((val) {
      setState(() {});
    });
  }

  void _onRefresh() async {
    widget.refresh().then((res) => setState(() => model = res));
    // if failed,use refreshFailed()
    widget.refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    // widget.refresh();
    // await Future.delayed(Duration(milliseconds: 1000));
    widget.refreshController.loadComplete();
  }

  setData() async {
    var response = await model;
    return response;
  }

  checkItem(item, int index) {
    var someShopSlected;
    if (item['inventoryQty'] > 0) {
      setState(
        () => {
          item['selected'] = !item['selected'],
          someShopSlected =
              model[index]['items'].indexWhere((c) => !c['selected']),
          if (someShopSlected == -1)
            model[index]['selected'] = true
          else
            model[index]['selected'] = false,
        },
      );
    }
  }

  checkAll(bool value) {
    model.forEach((e) => {
          e['selected'] = !value,
          e['items'].forEach((o) => {
                if (o['inventoryQty'] > 0) o['selected'] = !value,
              }),
        });
    setState(() {}); // mendatory
  }

  void deleteItem(BuildContext context, index, indexItem) async {
    Dio dio = new Dio();
    return await dio.post(server + 'm/cart/delete', data: {
      'code': model[index]['items'][indexItem]['code']
    }).then((res) async {
      dynamic data = res.data;
      if (data['status'] == 'S') {
        setState(() => model[index]['items'].removeAt(indexItem));
        if (model[index]['items'].length == 0) model.removeAt(index);
      }
    });
  }
}
