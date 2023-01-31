import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/manage_address_edit.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'widget/header.dart';

class ManageAddressPage extends StatefulWidget {
  ManageAddressPage({Key key, this.showEdit: false}) : super(key: key);

  final bool showEdit;
  @override
  _ManageAddressPageState createState() => _ManageAddressPageState();
}

class _ManageAddressPageState extends State<ManageAddressPage> {
  List<dynamic> model;
  Future<dynamic> _futureModel;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool selectOnly = false;
  int selectedIndexCategory = 0;
  var tempData = List<dynamic>();
  String status = '0';

  @override
  void initState() {
    setState(() {
      selectOnly = widget.showEdit;
    });
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
        appBar: header2(context,
            title: 'จัดการที่อยู่',
            func: () => Navigator.pop(context, {'status': status})),
        backgroundColor: Theme.of(context).backgroundColor,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _buildSmartRefresher(
            ListView(
              children: _buildList(),
            ),
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
      onRefresh: _onLoading,
      onLoading: _onLoading,
      child: child,
    );
  }

  _buildList() {
    return <Widget>[
      if (widget.showEdit)
        Container(
          height: 40,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 15),
          child: GestureDetector(
            onTap: () => setState(() => selectOnly = !selectOnly),
            child: Text(
              selectOnly ? 'แก้ไข' : 'ยกเลิกแก้ไข',
              style: TextStyle(
                  fontFamily: 'Kanit', fontSize: 15, color: Colors.red),
            ),
          ),
        ),
      FutureBuilder(
        future: _futureModel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return _buildItem(snapshot.data[index]);
                },
              );
            } else {
              status = '2';
              return Container(
                height: 120,
                child: Center(
                  child: Text(
                    'ยังไม่มีที่อยู่',
                    style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return DataError(onTap: () => _callRead());
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    LoadingTween(
                      height: 100,
                      width: double.infinity,
                    ),
                    SizedBox(height: 10)
                  ],
                );
              },
            );
          }
        },
      ),
      SizedBox(height: 60),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 35,
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).primaryColor,
            child: MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageAddressEditPage(),
                  ),
                ).then(
                  (value) => {if (value == 'success') _onLoading()},
                );
              },
              child: new Text(
                'เพิ่มที่อยู่ใหม่',
                style: new TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Kanit',
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 10),
    ];
  }

  _buildItem(dynamic model) {
    return InkWell(
      onTap: () async {
        if (selectOnly) {
          Navigator.pop(context, {'status': '1', ...model});
        } else
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageAddressEditPage(code: model['code']),
            ),
          ).then(
            (value) => {if (value == 'success') _onLoading()},
          );
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 105),
        width: double.infinity,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${model['title'] + ' ' + model['phone']}",
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  Text(
                    '${model['address']} \n${model['subDistrictTitle']} ${model['districtTitle']} \n${model['provinceTitle']} ${model['postalCode']}',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      color: Color(0xFF707070),
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
            if (model['isDefault'])
              InkWell(
                child: Container(
                  height: 22,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    'ค่าเริ่มต้น',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
    await _callRead();

    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    await _callRead();
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  _callRead() {
    for (var i = 0; i < 4; i++) {
      tempData.add({
        'name': '',
        'phone': '',
        'address': '',
        'province': '',
        'isDefault': i == 0 ? true : false
      });
    }
    _futureModel = postDio('${server}m/manageAddress/read', {});
  }
}
