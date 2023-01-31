import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/pages/warning/warning_list_vertical.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WarningList extends StatefulWidget {
  WarningList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WarningList createState() => _WarningList();
}

class _WarningList extends State<WarningList> {
  WarningListVertical warning;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch;
  String category;
  int _limit = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _onLoading();
    super.initState();
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      warning = new WarningListVertical(
        site: 'DDPM',
        model: post('${warningApi}read', {
          'skip': 0,
          'limit': _limit,
          "keySearch": keySearch,
          'category': category
        }),
        url: '${warningApi}read',
        urlGallery: '${warningGalleryApi}',
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
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
        backgroundColor: Colors.white,
        appBar: header(
          context,
          title: widget.title,
          isShowLogo: false,
          isCenter: true,
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: Column(
            children: [
              SizedBox(height: 5),
              CategorySelector(
                model: postDioCategory(
                  '${warningCategoryApi}read',
                  {'skip': 0, 'limit': 100},
                ),
                onChange: (String val) {
                  setState(
                    () => {
                      category = val,
                    },
                  );
                  _onLoading();
                },
              ),
              SizedBox(height: 5),
              KeySearch(
                show: hideSearch,
                onKeySearchChange: (String val) {
                  // warningList(context, post('${warningApi}read', {'skip': 0, 'limit': 100,"keySearch": val}),'');
                  setState(
                    () {
                      keySearch = val;
                    },
                  );
                  _onLoading();
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: ClassicFooter(
                    loadingText: ' ',
                    canLoadingText: ' ',
                    idleText: ' ',
                    idleIcon: Icon(
                      Icons.arrow_upward,
                      color: Colors.transparent,
                    ),
                  ),
                  controller: _refreshController,
                  onLoading: _onLoading,
                  child: ListView(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: [warning],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
