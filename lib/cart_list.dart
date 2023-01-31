import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wereward/component/cart/cart_item.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/widget/header.dart';

class CartListPage extends StatefulWidget {
  @override
  _CartListPageState createState() => _CartListPageState();
}

class _CartListPageState extends State<CartListPage> {
  final storage = new FlutterSecureStorage();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<dynamic> shopList = new List<dynamic>();
  List<dynamic> selectedList = new List<dynamic>();

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
        appBar: _buildAppBar(context),
        backgroundColor: Theme.of(context).backgroundColor,
        body: buildFutureBuilder(),
      ),
    );
  }

  buildFutureBuilder() {
    return FutureBuilder<dynamic>(
      future: _callRead(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return CartItemPage(
                model: snapshot.data,
                refreshController: _refreshController,
                refresh: () => _callRead());
          else
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'รถเข็นยังว่างอยู่ ต้องหาอะไรมาเพิ่มหน่อยแล้ว!',
                    style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
                  ),
                  SizedBox(height: 15),
                  Image.asset(
                    'assets/images/cart.png',
                    height: 80,
                    width: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 15),
                  InkWell(
                    onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeMartPage()),
                        (route) => false),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      child: Text(
                        'ช้อปตอนนี้',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _callRead());
        } else {
          return Stack(
            children: [
              _buildSmartRefresher(
                ListView.separated(
                  itemCount: 5,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemBuilder: (context, index) => LoadingTween(height: 200),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  height: 60 + MediaQuery.of(context).padding.bottom,
                  child: LoadingTween(
                    height: 60,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  _buildAppBar(BuildContext context) {
    return new PreferredSize(
      child: new Container(
        padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            new Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
              child: new Text(
                'รถเข็น',
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
      ),
      preferredSize: new Size(MediaQuery.of(context).size.width, 150.0),
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

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    _callRead();
    // await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() async {
    var uuid = Uuid();
    shopList = [];
    var newMap = {};
    var response = await postDio('${server}m/cart/read', {});

    newMap = groupBy(
        response,
        (obj) => [
              obj['referenceShopName'] != null ? obj['referenceShopName'] : '',
              obj['referenceShopCode'] != null ? obj['referenceShopCode'] : '',
            ]);
    newMap.forEach((key, value) async {
      var orderNoReference = uuid.v4();
      var items = value.map((e) {
        e['selected'] = false;
        e['referenceShopName'] = key[0];
        e['referenceShopCode'] = key[1];
        e['orderNoReference'] = orderNoReference;
        return e;
      }).toList();
      shopList.add({
        'code': key,
        'selected': false,
        'items': items,
      });
    });

    return shopList;
  }
}
