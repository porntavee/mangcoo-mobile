import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/product_card.dart';

class ShopItemListPage extends StatefulWidget {
  const ShopItemListPage(
      {Key key, this.model, @required this.referenceShopCode})
      : super(key: key);

  final dynamic model;
  final String referenceShopCode;

  @override
  _ShopItemListPageState createState() => _ShopItemListPageState();
}

class _ShopItemListPageState extends State<ShopItemListPage> {
  Future<dynamic> _futureModel;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _limit = 10;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header2(context, title: widget.model['title']),
      body: _buildSmartRefresher(_buildBody()),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.length);
          if (snapshot.data.length == 0) return Container();
          return GridView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data.length,
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.58,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  color: Colors.white,
                ),
                child: ProductCard(
                  model: snapshot.data[index],
                  width: (MediaQuery.of(context).size.width / 2) - 17.5,
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _onRefresh());
        } else {
          return Container();
        }
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
      // shrinkWrap: true, // use it
      physics: ClampingScrollPhysics(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          return Container(
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
      _limit = 10;
    });
    _callRead();

    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
    });
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() async {
    setState(() {
      _futureModel = postDio('${server}m/shop/goods/read', {
        widget.model['lv']: widget.model['code'],
        'referenceShopCode': widget.referenceShopCode,
        'limit': _limit,
      });
    });
  }
}
