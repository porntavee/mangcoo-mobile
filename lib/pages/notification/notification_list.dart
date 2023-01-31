import 'package:wereward/pages/notification/main_page_form.dart';
import 'package:wereward/pages/reporter/reporter_history_form.dart';
import 'package:wereward/pages/warning/warning_form.dart';
import 'package:wereward/pages/welfare/welfare_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/pages/blank_page/blank_loading.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/pages/event_calendar/event_calendar_form.dart';
import 'package:wereward/pages/knowledge/knowledge_form.dart';
import 'package:wereward/pages/news/news_form.dart';
import 'package:wereward/pages/poi/poi_form.dart';
import 'package:wereward/pages/poll/poll_form.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationList extends StatefulWidget {
  NotificationList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NotificationList createState() => _NotificationList();
}

class _NotificationList extends State<NotificationList> {
  Future<dynamic> _futureModel;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    _loading();
    super.initState();
  }

  _loading() async {
    // var profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null) {
    setState(() {
      _futureModel = postDio(
        '${notificationApi}read',
        {
          'skip': 0,
          'limit': 999,
          // 'profileCode': profileCode,
        },
      );
    });
    // }
  }

  checkNavigationPage(String page, dynamic model) {
    switch (page) {
      case 'newsPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsForm(
                url: newsApi + 'read',
                code: model['reference'],
                model: model,
                urlComment: newsCommentApi,
                urlGallery: newsGalleryApi,
              ),
            ),
          ).then((value) => {
                setState(() {
                  _futureModel =
                      postDio('${notificationApi}read', {'limit': 999});
                })
              });
        }
        break;

      case 'eventPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventCalendarForm(
                url: eventCalendarApi + 'read',
                code: model['reference'],
                model: model,
                urlComment: eventCalendarCommentApi,
                urlGallery: eventCalendarGalleryApi,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      // case 'privilegePage':
      //   {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => PrivilegeForm(
      //           code: model['reference'],
      //           model: model,
      //         ),
      //       ),
      //     ).then((value) => {_loading()});
      //   }
      //   break;

      case 'knowledgePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KnowledgeForm(
                code: model['reference'],
                model: model,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'poiPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoiForm(
                url: poiApi + 'read',
                code: model['reference'],
                model: model,
                urlComment: poiCommentApi,
                urlGallery: poiGalleryApi,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'pollPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PollForm(
                code: model['reference'],
                model: model,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'warningPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WarningForm(
                code: model['reference'],
                model: model,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'welfarePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WelfareForm(
                code: model['reference'],
                model: model,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'mainPage':
        {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainPageForm(
                code: model['reference'],
                model: model,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'reporterPage':
        {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReporterHistortForm(
                url: reporterReadApi,
                code: model['reference'],
                model: {
                  'title': '',
                  'description': '',
                  'imageUrl': '',
                  'imageUrlCreateBy': '',
                  'firstName': '',
                  'lastName': '',
                  'createDate': '20200131',
                  'latitude': '',
                  'longitude': ''
                },
                urlComment: '',
                urlGallery: '',
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      default:
        {
          return toastFail(context, text: 'เกิดข้อผิดพลาด');
        }
        break;
    }
  }

  void goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
        appBar: header(
          context,
          () => goBack(),
          title: widget.title,
          isButtonRight: true,
          rightButton: () => _handleClickMe(),
          menu: 'notification',
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: _futureModel, // function where you call your api
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length > 0) {
                return ListView.builder(
                  shrinkWrap: true, // 1st add
                  physics: ClampingScrollPhysics(), // 2nd
                  // scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return card(context, snapshot.data[index]);
                  },
                );
              } else {
                return Container(
                  width: width,
                  margin: EdgeInsets.only(top: height * 30 / 100),
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        width: width,
                        child: Image.asset(
                          'assets/images/logo.png',
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: height * 1 / 100),
                        alignment: Alignment.center,
                        width: width,
                        child: Text(
                          'ไม่พบข้อมูล',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return Container(
                width: width,
                height: height,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _futureModel = postDio(
                          '${notificationApi}read', {'skip': 0, 'limit': 999});
                    });
                  },
                  child: Icon(Icons.refresh, size: 50.0, color: Colors.blue),
                ),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true, // 1st add
                physics: ClampingScrollPhysics(), // 2nd
                // scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return BlankLoading(
                    width: width,
                    height: height * 15 / 100,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  card(BuildContext context, dynamic model) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
        onTap: () async {
          await postDio(
            '${notificationApi}update',
            {'category': '${model['category']}', "code": '${model['code']}'},
          );
          checkNavigationPage(model['category'], model);
          // .then((response) {
          //   if (response == 'S') {
          //     // checkNavigationPage(model['category'], model);
          //   }
          // })
        },
        child: Slidable(
          // fixflutter2 actionPane: SlidableDrawerActionPane(),
          // fixflutter2 actionExtentRatio: 0.25,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.2 / 100),
            height: (height * 15) / 100,
            width: width,
            decoration: BoxDecoration(
              color: model['status'] == 'A' ? Colors.white : Color(0xFFE7E7EE),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 1 / 100,
                      vertical: height * 1.2 / 100),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: height * 0.7 / 100, right: width * 1 / 100),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(height * 1 / 100),
                          color: model['status'] == 'A'
                              ? Colors.white
                              : Colors.red,
                        ),
                        height: height * 2 / 100,
                        width: height * 2 / 100,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            '${model['title']}',
                            style: TextStyle(
                              fontSize: (height * 2) / 100,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFFF7514),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 5 / 100,
                      vertical: height * 1.5 / 100),
                  child: Text(
                    '${dateStringToDate(model['createDate'])}',
                    style: TextStyle(
                      fontSize: (height * 1.7) / 100,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // fixflutter2 secondaryActions: <Widget>[
          //   IconSlideAction(
          //     caption: 'Delete',
          //     color: Colors.red,
          //     icon: Icons.delete,
          //     onTap: () {
          //       postDio('${notificationApi}delete', {
          //         'category': '${model['category']}',
          //         "code": '${model['code']}'
          //       });

          //       setState(() {
          //         _loading();
          //       });
          //     },
          //   ),
          // ],
        ));
  }

  Future<void> _handleClickMe() async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          // title: Text('ตัวเลือก'),
          // message: Text(''),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                'อ่านทั้งหมด',
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.normal,
                  color: Colors.lightBlue,
                ),
              ),
              onPressed: () {
                postDio('${notificationApi}update', {});

                setState(() {
                  _loading();
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                'ลบทั้งหมด',
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                ),
              ),
              onPressed: () async {
                await postDio('${notificationApi}delete', {});
                setState(() {
                  _loading();
                });
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('ยกเลิก',
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.normal,
                  color: Colors.lightBlue,
                )),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
