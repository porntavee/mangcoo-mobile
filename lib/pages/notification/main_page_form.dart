import 'package:wereward/component/button_close_back.dart';
import 'package:wereward/component/comment.dart';
import 'package:wereward/pages/notification/content_motifocation.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class MainPageForm extends StatefulWidget {
  MainPageForm({
    Key key,
    this.code,
    this.model,
  }) : super(key: key);

  final String code;
  final dynamic model;

  @override
  _MainPageForm createState() => _MainPageForm();
}

class _MainPageForm extends State<MainPageForm> {
  Comment comment;
  int _limit;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    setState(() {
      _limit = 10;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
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
        backgroundColor: Colors.white,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
            ),
            controller: _refreshController,
            onLoading: _onLoading,
            child: ListView(
              shrinkWrap: true,
              children: [
                Stack(
                  children: [
                    ContentNotification(
                      pathShare: 'content/main/',
                      code: widget.code,
                      url: notificationApi + 'detail',
                      model: widget.model,
                      urlGallery: notificationApi + 'gallery/read',
                    ),
                    Positioned(
                      right: 0,
                      top: statusBarHeight + 5,
                      child: Container(
                        child: buttonCloseBack(context),
                      ),
                    ),
                  ],
                ),
                // comment,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
