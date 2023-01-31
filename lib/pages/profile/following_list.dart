import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shop.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class FollowingList extends StatefulWidget {
  const FollowingList({Key key}) : super(key: key);

  @override
  _FollowingListState createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  Future<dynamic> _futureModel;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _read();
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
        appBar: header2(context, title: 'กำลังติดตาม'),
        body: FutureBuilder(
          future: _futureModel,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildSmartRefresher(_buildList(snapshot.data));
            } else if (snapshot.hasError) {
              return DataError(onTap: () => _read());
            } else {
              return LoadingTween(
                height: 100,
                width: double.infinity,
              );
            }
          },
        ),
      ),
    );
  }

  _buildList(model) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      itemCount: model.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        width: double.infinity,
        color: Colors.grey.withOpacity(0.7),
        margin: EdgeInsets.symmetric(vertical: 5),
      ),
      itemBuilder: (context, index) {
        return _buildItem(model, index);
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
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  InkWell _buildItem(model, int index) {
    return InkWell(
      highlightColor: Colors.white,
      onTap: () async {
        var response = await postDio(
            '${server}m/shop/read', {'code': model[index]['reference']});
        Navigator.push(
          context,
          fadeNav(
            ShopPage(model: response[0]),
          ),
        ).then((value) => _read());
      },
      child: Container(
        height: 60,
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: loadingImageNetwork(
              model[index]['imageUrl'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model[index]['title'],
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                  ),
                )
              ],
            ),
          ),
          StackTap(
            onTap: () => updateFollow(model[index]),
            child: Container(
              height: 25,
              width: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: Text(
                model[index]['isActive'] ? 'กำลังติดตาม' : 'เลิกติดตาม',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  void _onRefresh() async {
    _read();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _read();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _read() {
    setState(() {
      _futureModel = postDio(server + 'm/follow/following/read', {});
    });
  }

  updateFollow(model) async {
    await postDio(
        server + 'm/follow/create', {'reference': model['reference']});
    _read();
  }
}
