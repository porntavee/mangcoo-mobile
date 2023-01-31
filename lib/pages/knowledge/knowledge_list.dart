import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:wereward/pages/knowledge/knowledge_list_vertical.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class KnowledgeList extends StatefulWidget {
  KnowledgeList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _KnowledgeList createState() => _KnowledgeList();
}

class _KnowledgeList extends State<KnowledgeList> {
  KnowledgeListVertical gridView;
  final txtDescription = TextEditingController();
  bool hideSearch = true;
  String keySearch = '';
  String category = '';
  int _limit = 0;
  Future<dynamic> _futureCategory;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _onLoading();
    // gridView = new KnowledgeListVertical(
    //   site: 'DDPM',
    //   model: service
    //       .postDio('${knowledgeApi}read', {'skip': 0, 'limit': _limit}),
    // );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onLoading() async {
    // var profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null) {
    setState(() {
      _limit = _limit + 10;
      _futureCategory = postDioCategory(
        '${knowledgeCategoryApi}read',
        {
          'skip': 0,
          'limit': 100,
          // 'profileCode': profileCode,
        },
      );
      gridView = new KnowledgeListVertical(
        site: 'DDPM',
        model: postDio('${knowledgeApi}read', {
          'skip': 0,
          'limit': _limit,
          'category': category,
          "keySearch": keySearch,
          // 'profileCode': profileCode
        }),
      );
    });
    // }

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
        appBar: header(context,
            title: widget.title, isShowLogo: false, isCenter: true),
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: [
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
              SizedBox(
                height: 5.0,
              ),
              KeySearch(
                show: hideSearch,
                onKeySearchChange: (String val) {
                  setState(
                    () => {
                      keySearch = val,
                    },
                  );
                  _onLoading();
                },
              ),
              SizedBox(
                height: 10.0,
              ),
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
                    children: [gridView],
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
