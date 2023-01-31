import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/build_shop.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  RefreshController _refreshController;
  Future<dynamic> _futureModel;
  int _limit = 10;

  @override
  void initState() {
    _refreshController = RefreshController();
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
        appBar: header2(context, title: 'ดูล่าสุด'),
        body: _buildSmartRefresher(
          ListView(
            padding: EdgeInsets.symmetric(vertical: 10),
            children: [
              BuildShop(
                model: _futureModel,
                showHeader: false,
                showError: true,
                onError: () => _onRefresh(),
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
          if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("เกิดข้อผิดพลาด");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("");
          } else {
            body = Text("ไม่พบข้อมูลเพิ่มเติม");
          }
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
    setState(() {
      _limit = 10;
    });
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      _limit += 10;
    });
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() {
    setState(() {
      _futureModel =
          postDio(server + 'm/goods/history/read', {'limit': _limit});
    });
  }
}
