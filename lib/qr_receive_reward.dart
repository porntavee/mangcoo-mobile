import 'dart:async';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/component/menu/grid_content.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/qr_scanner.dart';
import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class QRReceiveRewardPage extends StatefulWidget {
  QRReceiveRewardPage({Key key, this.code}) : super(key: key);

  final String code;
  @override
  _QRReceiveRewardPageState createState() => _QRReceiveRewardPageState();
}

class _QRReceiveRewardPageState extends State<QRReceiveRewardPage> {
  Future<dynamic> futureModel;
  Future<dynamic> futurePromotionNews;
  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  var tempData = List<dynamic>();
  int _limit = 10;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header2(
        context,
        title: 'สแกน QR รับสิทธิ์',
      ),
      backgroundColor: Colors.white,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
                child: _buildSmartRefresher(
              _screen({'message': '', 'objectData': tempData}),
            )),
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

  _screen(dynamic model) {
    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        SizedBox(height: 10),
        if (keySearch != '')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'ผลการค้นหา ' + keySearch + ' ใน shop ',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
              ),
            ),
          ),
        SizedBox(height: 10),
        GridContent2(
          model: futureModel,
          navigationForm: (dynamic model) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => DetailShopPage(model: model),
            //   ),
            // );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRViewPage(model: model),
              ),
            );
          },
        ),
      ],
    );
  }

  _buildDialog(dynamic model) async {
    return await showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        final themeChange = Provider.of<DarkThemeProvider>(context);
        return CustomAlertDialog2(
          contentPadding: EdgeInsets.all(10),
          content: Container(
            height: 375,
            width: MediaQuery.of(context).size.width,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model['title'],
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              themeChange.darkTheme = themeChange.darkTheme;
                              // selectedType = '0';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'รหัส',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              themeChange.darkTheme = themeChange.darkTheme;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'บาร์โค๊ด',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              themeChange.darkTheme = themeChange.darkTheme;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'QR Code',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: loadingImageNetwork(
                      'https://www.imgonline.com.ua/examples/qr-code-url.png',
                      height: 130,
                      width: 130,
                      fit: BoxFit.fill),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    'ข้อมูลเพิ่มเติม',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((val) {
      setState(() {});
    });
  }

  void _onRefresh() async {
    setState(() {
      _limit = 10;
    });
    _callRead();

    // if failed,use refreshFailed()
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

  _callRead() {
    // print(widget.code);
    futureModel = postDio('${server}m/poi/read',
        {"limit": _limit, "category": widget.code, "keySearch": keySearch});

    for (var i = 0; i < 10; i++) {
      tempData.add({'title': '', 'imageUrl': ''});
    }
  }
}
