import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/my_credit_card_add.dart';
import 'package:wereward/my_credit_card_edit.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'widget/header.dart';

class MyCreditCardPage extends StatefulWidget {
  MyCreditCardPage({Key key, this.productList: dynamic}) : super(key: key);

  final dynamic productList;
  @override
  _MyCreditCardPageState createState() => _MyCreditCardPageState();
}

class _MyCreditCardPageState extends State<MyCreditCardPage> {
  List<dynamic> model;
  Future<dynamic> _futureModel;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var tempData = List<dynamic>();
  bool latestCard = false;

  @override
  void initState() {
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
        appBar: header2(context, title: 'ช่องทางการชำระเงิน'),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: _buildSmartRefresher(
            ListView(
              children: _buildList(),
            ),
          ),
        ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(height: 10),
      Text(
        'บัตรเครดิตของฉัน',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10),
      FutureBuilder(
        future: _futureModel,
        builder: (context, snap) {
          if (snap.hasData) {
            if (snap.data.length > 0) {
              return ListView.separated(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snap.data.length,
                itemBuilder: (context, index) => buildItem(snap.data[index]),
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
              );
            } else {
              return Container(
                height: 120,
                child: Center(
                  child: InkWell(
                    child: Text('ยังไม่มีรายการบัตรบัตรเครดิต',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              );
            }
          } else if (snap.hasError) {
            return DataError(onTap: () => _callRead());
          } else {
            return Container();
          }
        },
      ),
      SizedBox(height: 30),
      InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyCreditCardAddPage(),
          ),
        ).then((value) => {if (value == 'success') _onRefresh()}),
        child: Container(
          height: 35,
          constraints: BoxConstraints(maxWidth: 400, minWidth: 350),
          padding: EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFED5643),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'เพิ่มบัตรใหม่',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
    ];
  }

  InkWell buildItem(dynamic model) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCreditCardEditPage(
            code: model['code'],
          ),
        ),
      ).then((value) => _callRead()),
      child: Container(
        height: 35,
        constraints: BoxConstraints(maxWidth: 400, minWidth: 350),
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'บัตรเครดิตของฉัน',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              '*' + model['number'],
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Container buildSpaceGrey({double height = 5.0}) {
    return Container(
      height: height,
      width: double.infinity,
      color: Theme.of(context).backgroundColor,
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
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() {
    setState(() {
      _futureModel = postDio('${server}m/manageCreditCard/read', {});
    });
  }
}
