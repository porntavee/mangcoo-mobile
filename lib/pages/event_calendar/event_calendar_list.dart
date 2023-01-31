import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wereward/component/key_search.dart';
import 'package:wereward/pages/event_calendar/event_calendar_list_vertical.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EventCalendarList extends StatefulWidget {
  EventCalendarList({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _EventCalendarList createState() => _EventCalendarList();
}

class _EventCalendarList extends State<EventCalendarList> {
  final storage = new FlutterSecureStorage();

  EventCalendarList eventCalendarList;
  EventCalendarListVertical gridView;

  bool hideSearch = true;
  List<dynamic> listData = [];
  List<dynamic> category = [];
  bool isMain = true;
  String categorySelected = '';
  String keySearch = '';
  bool isHighlight = false;
  int _limit = 10;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // _futureEventCalendarCategory =
    //     post('${eventCalendarCategoryApi}read', {'skip': 0, 'limit': 100});
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
        backgroundColor: Colors.white,
        // appBar: header(context, goBack, title: widget.title),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Column(
              children: [
                SizedBox(
                  height: 5.0,
                ),
                _buildCategory(),
                SizedBox(
                  height: 10.0,
                ),
                KeySearch(
                  show: hideSearch,
                  onKeySearchChange: (String val) {
                    setState(() {
                      keySearch = val;
                    });
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
                      idleIcon:
                          Icon(Icons.arrow_upward, color: Colors.transparent),
                    ),
                    controller: _refreshController,
                    onLoading: _onLoading,
                    child: ListView(
                      children: [_buildList()],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildCategory() {
    return FutureBuilder<dynamic>(
      future: postDioCategory(
        '${eventCalendarCategoryApi}read',
        {'skip': 0, 'limit': 100},
      ), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (snapshot.data[index]['code'] != '') {
                      setState(() {
                        // keySearch = '';
                        // isMain = false;
                        categorySelected = snapshot.data[index]['code'];
                      });
                    } else {
                      setState(() {
                        // isHighlight = true;
                        categorySelected = '';
                        isMain = true;
                      });
                    }
                    setState(() {
                      categorySelected = snapshot.data[index]['code'];
                      // selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color: categorySelected == snapshot.data[index]['code']
                            ? Colors.black
                            : Colors.grey,
                        decoration:
                            categorySelected == snapshot.data[index]['code']
                                ? TextDecoration.underline
                                : null,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  _buildList() {
    return gridView = new EventCalendarListVertical(
      site: 'DDPM',
      model: post('${eventCalendarApi}read', {
        'skip': 0,
        'limit': _limit,
        'keySearch': keySearch != null ? keySearch : '',
        'isHighlight': isHighlight != null ? isHighlight : false,
        'category': categorySelected != null ? categorySelected : ''
      }),
      urlGallery: eventCalendarGalleryApi,
      urlComment: eventCalendarCommentApi,
      url: '${eventCalendarApi}read',
    );
  }

  _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      return gridView = new EventCalendarListVertical(
        site: 'CIO',
        model: post('${eventCalendarApi}read', {
          'skip': 0,
          'limit': _limit,
          'keySearch': keySearch != null ? keySearch : '',
          'isHighlight': isHighlight != null ? isHighlight : false,
          'category': categorySelected != null ? categorySelected : ''
        }),
        urlGallery: eventCalendarGalleryApi,
        urlComment: eventCalendarCommentApi,
        url: '${eventCalendarApi}read',
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  _read() async {
    // var profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null) {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 999 // integer value type
    });
    var response = await http.post(Uri.parse(eventCalendarCategoryApi + 'read'),
        body: body,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        });

    var data = json.decode(response.body);
    setState(() {
      category = data['objectData'];
    });

    if (category.length > 0) {
      for (int i = 0; i <= category.length - 1; i++) {
        var res = post('${eventCalendarApi}read', {
          'skip': 0,
          'limit': 100,
          'category': category[i]['code'],
          'keySearch': keySearch,
          // 'profileCode': profileCode
        });
        listData.add(res);
      }
    }
    // }
  }
}
