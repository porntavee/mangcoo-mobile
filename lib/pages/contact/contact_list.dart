import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/pages/contact/contact_list_vertical.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContactList extends StatefulWidget {
  ContactList({
    Key key,
    this.title,
    this.code,
  }) : super(key: key);

  final String title;
  final String code;

  @override
  _ContactList createState() => _ContactList();
}

class _ContactList extends State<ContactList> {
  ContactListVertical contact;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch = '';
  String category = '';
  int _limit = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final storage = new FlutterSecureStorage();

  Future<dynamic> _futureContact;

  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // _controller.addListener(_scrollListener);

    _onLoading();

    super.initState();
  }

  void _onLoading() async {
    // var profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null) {
    setState(() {
      _limit = _limit + 10;
      _futureContact = postDio('${contactApi}read', {
        'skip': 0,
        'limit': _limit,
        'category': widget.code,
        'keySearch': keySearch,
        // 'profileCode': profileCode
      });

      contact = new ContactListVertical(
        site: "DDPM",
        model: _futureContact,
        title: "",
        url: '${contactApi}read',
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
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                SizedBox(height: 10),
                KeySearch(
                  show: hideSearch,
                  onKeySearchChange: (String val) {
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
                      idleIcon: Icon(
                        Icons.arrow_upward,
                        color: Colors.transparent,
                      ),
                    ),
                    controller: _refreshController,
                    onLoading: _onLoading,
                    child: ListView(
                      physics: ScrollPhysics(), shrinkWrap: true,
                      // controller: _controller,
                      children: [
                        ContactListVertical(
                          site: "DDPM",
                          model: _futureContact,
                          title: "",
                          url: '${contactApi}read',
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
