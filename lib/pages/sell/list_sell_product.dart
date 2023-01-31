import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/pages/sell/edit_product.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class ListSellProduct extends StatefulWidget {
  const ListSellProduct({Key key}) : super(key: key);

  @override
  _ListSellProductState createState() => _ListSellProductState();
}

class _ListSellProductState extends State<ListSellProduct> {
  final storage = new FlutterSecureStorage();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  dynamic tempData = {};
  Future<dynamic> _futureModel;
  @override
  void initState() {
    _callRead();
    super.initState();
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
        appBar: header2(context, title: 'สินค้าที่ลงขาย'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: _buildFutureBuilder(),
            ),
          ],
        ),
      ),
    );
  }

  _buildFutureBuilder() {
    return FutureBuilder(
      future: _futureModel,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildSmartRefresher(_buildBody(snapshot.data));
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _callRead());
        } else {
          return _buildSmartRefresher(_buildBody(tempData));
        }
      },
    );
  }

  _buildBody(model) {
    return ListView.separated(
      itemBuilder: (context, index) => _buildCard(model[index]),
      separatorBuilder: (context, index) => SizedBox(height: 8),
      itemCount: model.length,
    );
  }

  _buildCard(item) {
    return StackTap(
      onTap: () => Navigator.push(
        context,
        scaleTransitionNav(
          EditProductPage(model: item),
        ),
      ).then((value) => _onRefresh()),
      child: Container(
        height: 160,
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                loadingImageNetwork(
                  item['imageUrl'],
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontFamily: 'Kaint',
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '฿ ' + priceFormat.format(item['netPrice']),
                        style: TextStyle(
                          fontFamily: 'Kaint',
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            _buildLine(),
            Container(
              height: 25,
              width: double.infinity,
              child: Row(
                children: [
                  _buildAmountItem(
                    Icon(
                      Icons.stacked_bar_chart,
                      size: 17,
                      color: Colors.grey,
                    ),
                    ' คลัง ' + priceFormat.format(item['minPrice']),
                  ),
                  _buildAmountItem(
                    Icon(
                      Icons.outbond_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    ' ขายแล้ว ' + priceFormat.format(item['minPrice']),
                  ),
                ],
              ),
            ),
            Container(
              height: 25,
              width: double.infinity,
              child: Row(
                children: [
                  _buildAmountItem(
                    Icon(
                      Icons.star,
                      size: 17,
                      color: Colors.grey,
                    ),
                    ' ถูกใจ ' + priceFormat.format(item['minPrice']),
                  ),
                  _buildAmountItem(
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    ' ยอดเข้าชม ' + priceFormat.format(item['minPrice']),
                  ),
                ],
              ),
            ),
            _buildLine()
          ],
        ),
      ),
    );
  }

  Expanded _buildAmountItem(Icon icon, String title) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          icon,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Kaint',
                fontSize: 13,
                color: Colors.grey,
              ),
              maxLines: 1,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  _buildLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey.withOpacity(0.3),
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

  void _onRefresh() async {
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() async {
    var referenceShopCode = await storage.read(key: 'referenceShopCode');

    setState(() {
      _futureModel = postDio(server + 'm/goods/shop/read',
          {'referenceShopCode': referenceShopCode});
    });
  }
}
