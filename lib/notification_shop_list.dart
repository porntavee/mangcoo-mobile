import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/cart/cart_button_confirm.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/pdf_viewer_page.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/send_order.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class NotificationShopListPage extends StatefulWidget {
  const NotificationShopListPage({Key key}) : super(key: key);

  @override
  _NotificationShopListPageState createState() =>
      _NotificationShopListPageState();
}

class _NotificationShopListPageState extends State<NotificationShopListPage> {
  final storage = new FlutterSecureStorage();
  RefreshController _refreshController;
  Future<dynamic> _futureModel;
  int _limit = 10;
  dynamic model;
  bool selectAll = false;
  @override
  void initState() {
    _refreshController = new RefreshController();
    _callRead();
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
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: header2(context, title: 'แจ้งเตือน'),
        body: _buildBody(),
      ),
    );
  }

  _buildBody() {
    return FutureBuilder(
      future: _futureModel,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          model = snapshot.data;
          if (snapshot.data.length == 0)
            return Center(
              child: Text(
                'ไม่มีรายการสั่งซื้อ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 16,
                ),
              ),
            );
          return Stack(
            children: [
              _buildSmartRefresher(
                ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data.length,
                  padding: EdgeInsets.only(top: 40),
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemBuilder: (_, __) =>
                      _buildOrderItemSelect(snapshot.data[__]),
                ),
              ),
              Container(
                height: 40,
                color: Color(0xFFE84C10),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => checkAll(selectAll),
                        child: Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          // width: 300,
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  buildCheckItemAll(selectAll),
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if (model
                                .where((i) => i['selected'] == true)
                                .toList()
                                .length >
                            0)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => FlutterDemo(storage: CounterStorage()),
                              builder: (context) => PdfViewerPagePost(
                                path: '${serverReport}printOut/printOut',
                                model: model
                                    .where((i) => i['selected'] == true)
                                    .toList(),
                              ),
                            ),
                          );
                        else
                          toastFail(
                            context,
                            text: 'กรุณาเลือกสินค้า',
                            color: Colors.white,
                            fontColor: Colors.red,
                          );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'โหลดเอกสาร',
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
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _onRefresh());
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildOrderItemSelect(model) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            fadeNav(
              SendOrderPage(model: model),
            ),
          ).then((value) => _onRefresh()),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async => await checkItem(model), // index ร้่านค้า
                  child: buildCheckItem(model['selected'] ?? false),
                ),
                SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: loadingImageNetwork(model['imageUrl'],
                      height: 70, width: 70),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'คุณได้รับการแจ้งเตือน รายการสั่งซื้อสินค้า',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${model['goodsTitle']}',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(model) {
    return StackTap(
      onTap: () => Navigator.push(
        context,
        fadeNav(
          SendOrderPage(model: model),
        ),
      ).then((value) => _onRefresh()),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child:
                  loadingImageNetwork(model['imageUrl'], height: 70, width: 70),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คุณได้รับการแจ้งเตือน รายการสั่งซื้อสินค้า',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${model['goodsTitle']}',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            )
          ],
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
            height: 15.0,
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

  void _onRefresh() async {
    setState(() {
      _limit = _limit + 10;
    });
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      _limit = _limit + 10;
    });
    _callRead();
    _refreshController.loadComplete();
  }

  _callRead() async {
    var referenceShopCode = await storage.read(key: 'referenceShopCode');

    setState(() {
      _futureModel = postDio(server + 'm/cart/order/shop/read',
          {'referenceShopCode': referenceShopCode});
    });
  }

  checkAll(bool value) {
    model.forEach((e) => {
          e['selected'] = !value,
        });
    setState(() {}); // mendatory
    selectAll = model.toList().length ==
        model.where((i) => i['selected'] == true).toList().length;
  }

  checkItem(item) {
    setState(
      () => {
        item['selected'] = !(item['selected'] ?? false),
      },
    );
    selectAll = model.toList().length ==
        model.where((i) => i['selected'] == true).toList().length;
  }

  InkWell buildCheckItemAll(check) {
    return InkWell(
      onTap: () => checkAll(check),
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
}
