import 'package:flutter/material.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/pages/fund/fund_list_vertical.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FundList extends StatefulWidget {
  FundList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FundList createState() => _FundList();
}

class _FundList extends State<FundList> {
  FundListVertical fund;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch;
  String category;
  int _limit = 0;
  Future<dynamic> _futureCategory;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final storage = new FlutterSecureStorage();

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
    // _controller.addListener(_scrollListener);
    super.initState();
  }

  _onLoading() async {
    // var profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null) {
    setState(() {
      _limit = _limit + 10;
      _futureCategory = postDioCategory(
        '${fundCategoryApi}read',
        {
          'skip': 0,
          'limit': 100,
          // 'profileCode': profileCode,
        },
      );

      fund = new FundListVertical(
        // fund = new FundListVertical(
        site: "DDPM",
        model: postDio('${fundApi}read', {
          'skip': 0,
          'limit': _limit,
          'category': category,
          "keySearch": keySearch,
          // 'profileCode': profileCode
        }),
        url: '${fundApi}read',
        urlComment: '${fundCommentApi}',
        urlGallery: '${fundGalleryApi}',
      );
    });
    // }

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => Menu(),
    //   ),
    // );
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
        appBar: header(context, goBack, title: widget.title),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: Column(
            // physics: ScrollPhysics(),
            // shrinkWrap: true,
            // controller: _controller,
            children: [
              // SubHeader(th: "ข่าวสารประชาสัมพันธ์", en: "Fund"),
              SizedBox(height: 5),
              CategorySelector(
                model: _futureCategory,
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
                  // fundList(context, post('${fundApi}read', {'skip': 0, 'limit': 100,"keySearch": val}),'');
                  setState(
                    () => {
                      keySearch = val,
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
                    // controller: _controller,
                    children: [fund],
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
