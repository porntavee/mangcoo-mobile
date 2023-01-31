import 'package:flutter/material.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/pages/cooperative/cooperative_list_vertical.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/component/tab_category.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CooperativeList extends StatefulWidget {
  CooperativeList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CooperativeList createState() => _CooperativeList();
}

class _CooperativeList extends State<CooperativeList> {
  CooperativeListVertical gridView;
  final txtDescription = TextEditingController();
  bool hideSearch = true;
  String keySearch = '';
  String category = '';
  int _limit = 0;
  Future<dynamic> _futureCategory;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final storage = new FlutterSecureStorage();

  // Future<dynamic> _futureCooperative;

  @override
  void initState() {
    super.initState();

    gridView = new CooperativeListVertical(
      site: 'DDPM',
      model: postDio('${cooperativeApi}read', {'skip': 0, 'limit': _limit}),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  void _onLoading() async {
    // var profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null) {
    setState(() {
      _limit = _limit + 10;
      _futureCategory = postDioCategory(
        '${cooperativeCategoryApi}read',
        {
          'skip': 0,
          'limit': 100,
          // 'profileCode': profileCode,
        },
      );

      gridView = new CooperativeListVertical(
        site: 'DDPM',
        model: postDio('${cooperativeApi}read', {
          'skip': 0,
          'limit': _limit,
          "keySearch": keySearch,
          'category': category,
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
        appBar: header(context, goBack, title: 'วารสารสหกรณ์'),
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            header: WaterDropHeader(
              complete: Container(
                child: Text(''),
              ),
              completeDuration: Duration(milliseconds: 0),
            ),
            footer: ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
            ),
            controller: _refreshController,
            onLoading: _onLoading,
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
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
                gridView,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
