import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/cart/cart_item.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/data_not_found.dart';
import 'package:wereward/component/material/form_content_shop.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:flutter/material.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/order_detail.dart';
import 'package:wereward/review_page.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final storage = new FlutterSecureStorage();
  Future<dynamic> _futureModel;
  List<dynamic> categoryList;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String category = '';
  String selectedIndexCategory = "";
  var tempData = List<dynamic>();

  @override
  void initState() {
    categoryList = [
      {'title': 'ทั้งหมด', 'value': ''},
      {'title': 'รอชำระเงิน', 'value': 'V'},
      {'title': 'รอจัดส่ง', 'value': 'W'},
      {'title': 'อยู่ระหว่างการจัดส่ง', 'value': 'P'},
      {'title': 'เสร็จสิ้น', 'value': 'A'},
      {'title': 'ยกเลิก', 'value': 'R'},
    ];
    _callRead();
    super.initState();
  }

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
        backgroundColor: Theme.of(context).backgroundColor,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              _buildHead(),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'ดำเนินการโดย $appName',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 13,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                child: _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildHead() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      padding:
          EdgeInsets.only(bottom: 10, top: MediaQuery.of(context).padding.top),
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      'รายการสั่งซื้อ',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _categorySelector(
                model: categoryList,
                onChange: (String val) {
                  setState(
                    () => {},
                  );
                  _onLoading();
                },
              ),
            ],
          ),
        ),
      ),
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
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  _buildList() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return _buildSmartRefresher(ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildOrderGroupByShop(snapshot.data[index]);
              },
            ));
          } else {
            return DataNotFound();
          }
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _callRead());
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 10,
            itemBuilder: (context, index) {
              return LoadingTween();
            },
          );
        }
      },
    );
  }

  // List<OrderGroupByShop>
  _buildOrderGroupByShop(listOrderByShop) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        fadeNav(
          OrderDetailPage(model: listOrderByShop),
        ),
      ).then(
        (value) => _onRefresh(),
      ),
      onLongPress: () => updateStatus(listOrderByShop[0]['items'][0]),
      child: Container(
        padding: EdgeInsets.only(top: 11, right: 15, left: 15),
        color: Color(0xFFFFFFFF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            statusText(listOrderByShop[0]['items'][0]['status']),
            ..._buildItemsBody(listOrderByShop),
          ],
        ),
      ),
    );
  }

  Row _buildReviewBtn(model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        model['reviewed']
            ? StackTap(
                onTap: () => {},
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: Text(
                    'ให้คะแนนแล้ว',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kanit',
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            : StackTap(
                onTap: () => Navigator.push(
                  context,
                  scaleTransitionNav(
                    ReviewPage(model: model),
                  ),
                ).then((value) => _onRefresh()),
                borderRadius: BorderRadius.circular(3),
                splashColor: Colors.red.withOpacity(0.3),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: Text(
                    'เขียนรีวิว',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Kanit',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
        SizedBox(width: 8),
        StackTap(
          onTap: () => Navigator.push(
            context,
            fadeNav(FormContentShop(
              model: {
                'code': model['goodsCode'],
                'imageUrl': model['imageUrl']
              },
            )),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 30,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.redAccent, width: 1),
            ),
            child: Text(
              'สั่งอีกครั้ง',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Kanit',
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // items List<OrderGroupByShop>
  List<Widget> _buildItemsBody(items) {
    return items
        .map<Widget>((item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                _buildLine(),
                SizedBox(height: 3),
                StackTap(
                  onTap: () => {
                    //   Navigator.push(
                    //   context,
                    //   fadeNav(
                    //     ShopPage(
                    //       model: {'code': item['shopCode']},
                    //     ),
                    //   ),
                    // )
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.add_business, color: Colors.grey),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item['shopName'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 20)
                    ],
                  ),
                ),
                SizedBox(height: 3),
                _buildLine(),
                SizedBox(height: 5),
                ...item['items'].map<Widget>((e) => _buildBodyItem(e)).toList(),
                ...item['items'].map<Widget>(
                  (e) => StackTap(
                    onTap: () => {},
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e['qty'].toString() + ' ชิ้น',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'รวมการสั่งซื้อ ฿${priceFormat.format(e['netPrice'] * e['qty'])}',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ...item['items'].map<Widget>(
                  (e) => e['status'] == 'A'
                      ? Container()
                      : e['status'] == 'P'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                StackTap(
                                  onTap: () => {},
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                StackTap(
                                  onTap: () =>
                                      updateStatus(items[0]['items'][0]),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    width: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'ฉันได้ตรวจสอบและยอมรับสินค้า',
                                      style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                StackTap(
                                  onTap: () => {
                                    //   Navigator.push(
                                    //   context,
                                    //   fadeNav(
                                    //     ShopPage(
                                    //       model: {'code': item['shopCode']},
                                    //     ),
                                    //   ),
                                    // )
                                  },
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'ติดต่อผู้ขาย',
                                    style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
                SizedBox(height: 10),
              ],
            ))
        .toList();
  }

  _buildLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildBodyItem(model) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Hero(
          //   tag: model['code'],
          //   child:
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey[400])),
            child: loadingImageNetwork(
              model['imageUrl'],
              height: 100,
              width: 100,
            ),
          ),
          // ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 100,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Expanded(
                    child: Text(
                      model['title'].toString(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: 'Kanit',
                        fontSize: 13,
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
                        priceFormat.format(model['netPrice']),
                        //priceFormat.format(model['netPrice'] * model['qty']),
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
                  if (model['status'] == 'A') _buildReviewBtn(model),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categorySelector({dynamic model, Function onChange}) {
    return Container(
      height: 25.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              setState(() {
                selectedIndexCategory = model[index]['value'];
                _futureModel = postDio('${server}m/cart/order/read',
                    {'status': selectedIndexCategory});
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10),
              decoration: new BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
                borderRadius: new BorderRadius.circular(12.5),
                color: model[index]['value'] == selectedIndexCategory
                    ? Theme.of(context).accentColor
                    : Color(0xFFFFFFFF),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 7.0,
              ),
              child: Text(
                model[index]['title'],
                style: TextStyle(
                  color: model[index]['value'] == selectedIndexCategory
                      ? Color(0xFFFFFFFF)
                      : Theme.of(context).accentColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2,
                  fontFamily: 'Kanit',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  statusText(String status) {
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
        color = Colors.grey;
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

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.only(left: 13, right: 13, top: 5),
      height: 30,
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontFamily: 'Kanit',
          fontSize: 13,
        ),
      ),
    );
  }

  void _onRefresh() async {
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    // _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }

  _callRead() async {
    setState(() {
      _futureModel = postDio(
          '${server}m/cart/order/read', {'status': selectedIndexCategory});
    });
  }

  updateStatus(item) async {
    var status = item['status'];
    if (item['status'] == 'W') status = 'P';
    if (item['status'] == 'P') status = 'A';
    await postDio('${server}m/cart/order/status/update', {
      'code': item['orderNoReference'],
      'status': status,
    });
    _onRefresh();
  }
}
