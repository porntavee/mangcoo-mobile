import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/image_picker.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/photo_view.dart';
import 'package:wereward/widget/stack_tap.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key key,
    @required this.referenceShopCode,
    @required this.profileCode,
    @required this.isProfileSend,
    @required this.callByProfile,
  }) : super(key: key);

  final String referenceShopCode;
  final String profileCode;
  final bool isProfileSend;
  final bool callByProfile;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final storage = new FlutterSecureStorage();
  TextEditingController messageController;
  RefreshController _refreshController;
  Future<dynamic> _futureModel;
  String image = '';
  bool showLoading = false;
  int _limit = 10;
  Dio dio = new Dio();

  @override
  void initState() {
    messageController = new TextEditingController();
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
        appBar: header2(context, title: 'พูดคุย'),
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              _buildFutureBuilder(),
              _buildMessageSend(),
              if (showLoading) _buildshowLoading(),
            ],
          ),
        ),
      ),
    );
  }

  _buildshowLoading() {
    return Positioned.fill(
      child: Container(
        color: Colors.grey.withOpacity(0.8),
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
          return DataError(onTap: () => _onRefresh());
        } else
          return Container();
      },
    );
  }

  _buildBody(model) {
    return ListView.separated(
      reverse: true,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 70,
        left: 10,
        right: 10,
      ),
      itemCount: model.length,
      separatorBuilder: (context, index) => SizedBox(height: 13),
      itemBuilder: (context, index) => _buildItem(model[index]),
    );
  }

  _buildItem(model) {
    // ถ้าเป็น user และ user เป็นคนอ่าน
    // if shop and shop read.

    bool focusRight = false;
    if (widget.callByProfile && model['isProfileSend'] ||
        !widget.callByProfile && !model['isProfileSend']) {
      focusRight = true;
    }
    var createDate = model['createDate'];
    String year = createDate.substring(0, 4);
    String month = createDate.substring(4, 6);
    String day = createDate.substring(6, 8);
    String time = model['createTime'].toString().substring(0, 5);
    String date = day + '-' + month + '-' + year + ' : ' + time;
    return Column(
      crossAxisAlignment:
          focusRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              focusRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () async =>
                  await FlutterClipboard.copy(model['title']).then(
                (value) => toastFail(context, text: '✓  คัดลอกสำเร็จ'),
              ),
              child: model['imageUrl'] != ''
                  ? GestureDetector(
                      onTap: () => {
                        FocusScope.of(context).unfocus(),
                        Navigator.push(
                          context,
                          fadeNav(PhotoViewPage(image: model['imageUrl'])),
                        )
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(focusRight ? 20 : 0),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(focusRight ? 0 : 20),
                        ),
                        child: loadingImageNetwork(
                          model['imageUrl'],
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width * 0.7),
                      ),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: focusRight ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(focusRight ? 20 : 0),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(focusRight ? 0 : 20),
                        ),
                      ),
                      child: Text(
                        model['title'],
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
              right: focusRight ? 8 : 0, left: !focusRight ? 8 : 0),
          child: Text(
            date,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }

  _buildMessageSend() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        height: 56 + MediaQuery.of(context).padding.bottom,
        child: Row(
          children: [
            SizedBox(width: 11),
            ImageUploadPicker(
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.black,
              ),
              callback: (file) => {
                FocusScope.of(context).unfocus(),
                _uploadImage(file),
              },
            ),
            SizedBox(width: 11),
            Expanded(
              child: TextField(
                autofocus: false,
                style: new TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.4),
                  hintText: 'ข้อความ...',
                  contentPadding:
                      new EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
                controller: messageController,
              ),
            ),
            SizedBox(width: 11),
            StackTap(
              onTap: () async => {
                FocusScope.of(context).unfocus(),
                sendMessage(),
              },
              child: Icon(
                Icons.send_rounded,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 11),
          ],
        ),
      ),
    );
  }

  _buildSmartRefresher(Widget child) {
    return SmartRefresher(
      enablePullDown: false,
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

  _uploadImage(file) {
    setState(() {
      showLoading = true;
    });
    uploadImage(file).then((res) async {
      setState(() => image = res);
      sendMessage();
    }).catchError((err) {
      setState(() {
        showLoading = false;
      });
      print(err);
    });
  }

  void _onRefresh() async {
    setState(() {
      _limit = _limit + 10;
    });
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      _limit = _limit + 10;
    });
    _callRead();
    _refreshController.loadComplete();
  }

  _callRead() async {
    setState(() {
      _futureModel = dio.post(server + 'm/chat/read', data: {
        'referenceShopCode': widget.referenceShopCode,
        'profileCode': widget.profileCode,
        'limit': _limit,
        'isProfileSend': widget.isProfileSend,
      }).then((value) => Future.value(value.data['objectData']));
      showLoading = false;
    });
  }

  sendMessage() async {
    var response;
    var isProfileSend = false;
    widget.callByProfile ? isProfileSend = true : isProfileSend = false;
    if (messageController.text != '' || image != '') {
      setState(() => showLoading = true);
      response = await dio.post(server + 'm/chat/create', data: {
        'referenceShopCode': widget.referenceShopCode,
        'profileCode': widget.profileCode,
        'title': messageController.text,
        'imageUrl': image,
        'isProfileSend': isProfileSend,
      });

      setState(() => image = '');

      var result = Future.value(response.data['objectData']);
      if (result != null) {
        messageController = new TextEditingController();
        _onLoading();
      } else
        toastFail(context);
    }
  }
}
