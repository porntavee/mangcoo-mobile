import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/chat.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final storage = new FlutterSecureStorage();
  RefreshController _refreshController;
  Future<dynamic> _futureModel;
  int _limit = 10;
  String referenceShopCode = '';
  String profileCode = '';

  @override
  void initState() {
    _refreshController = new RefreshController();
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
        appBar: header2(context, title: 'ตอบกลับ'),
        body: _buildFutureBuilder(),
      ),
    );
  }

  _buildFutureBuilder() {
    return FutureBuilder(
      future: _futureModel,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0)
            return Center(
              child: Text(
                'ไม่พบรายการแซท',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            );
          return _buildSmartRefresher(_buildBody(snapshot.data));
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _onRefresh());
        } else
          return Container();
      },
    );
  }

  _buildBody(model) {
    return ListView.separated(
      itemBuilder: (context, index) => _buildItem(model[index]),
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Colors.grey[300],
        margin: EdgeInsets.symmetric(horizontal: 10),
      ),
      itemCount: model.length,
    );
  }

  _buildItem(model) {
    return StackTap(
      onTap: () {
        Navigator.push(
          context,
          scaleTransitionNav(
            ChatPage(
              referenceShopCode: model['referenceShopCode'],
              profileCode: model['profileCode'],
              isProfileSend:
                  referenceShopCode == null || referenceShopCode == ''
                      ? true
                      : false,
              callByProfile:
                  referenceShopCode == null || referenceShopCode == ''
                      ? true
                      : false,
            ),
          ),
        ).then((value) => _onRefresh());
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: loadingImageNetwork(
                model['imageUrl'],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          model['name'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        chatFormatDate(model['createDate'], model['docTime']),
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          model['title'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      _buildWidgetUnread(model)
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildWidgetUnread(model) {
    if (!model['readed']) {
      if (referenceShopCode == model['referenceShopCode'] &&
              !model['isProfileSend'] ||
          profileCode == model['profileCode'] && model['isProfileSend']) {
        return Container();
      } else {
        return Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        );
      }
    } else {
      return Container();
    }
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
    referenceShopCode = await storage.read(key: 'referenceShopCode');
    profileCode = await storage.read(key: 'profileCode10');
    var path = server + 'm/chat/listuser/read';
    if (referenceShopCode == '' || referenceShopCode == null)
      path = server + 'm/chat/listShop/read';
    setState(() {
      _futureModel = postDio(path, {
        'referenceShopCode': referenceShopCode,
      });
    });
  }
}
