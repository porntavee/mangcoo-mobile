import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class HowToUsePage extends StatefulWidget {
  HowToUsePage({
    Key key,
    this.navTo,
  }) : super(key: key);

  final Function navTo;

  @override
  _HowToUsePage createState() => _HowToUsePage();
}

class _HowToUsePage extends State<HowToUsePage> {
  int _limit;
  DateTime currentBackPressTime;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScrollController scrollController;

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
    scrollController = new ScrollController();

    _read();

    super.initState();
  }

  Future<dynamic> _futureModel;
  int currentCardIndex = 0;
  int policyLength = 0;
  bool lastPage = false;

  List acceptPolicyList = [];

  _read() async {
    _futureModel = postDio(server + "m/news/read", {
      "skip": 0,
      "limit": 10,
    });
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
        body: WillPopScope(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overScroll) {
                overScroll.disallowGlow();
                return false;
              },
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overScroll) {
                  overScroll.disallowGlow();
                  return false;
                },
                child: Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  alignment: Alignment.center,
                  height: double.infinity,
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     alignment: Alignment.topCenter,
                  //     image: AssetImage('assets/images/background_policy.png'),
                  //   ),
                  // ),
                  child: _futureBuilderModel(),
                  // child: _screen(),
                ),
              ),
            ),
            onWillPop: null),
      ),
    );
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  _futureBuilderModel() {
    return FutureBuilder<dynamic>(
      future: _futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _screen(snapshot.data);
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return _screen([
            {'title': '', 'imageUrl': '', 'description': ''}
          ]);
        }
      },
    );
  }

  _screen(dynamic model) {
    policyLength = model.length;
    return Column(
      children: [
        Expanded(
          child: _buildCard(model[currentCardIndex]),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(
                'กลับ',
                Color(0xFF707070),
                onTap: () {
                  previousIndex();
                },
              ),
              _buildButton(
                currentCardIndex == policyLength - 1 ? 'ตกลง' : 'ต่อไป',
                Color(0xFF00cc00),
                onTap: () {
                  currentCardIndex == policyLength - 1
                      ? Navigator.pop(context)
                      : nextIndex();
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  _buildCard(dynamic model) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                model['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFFEEBA33),
              ),
              child: Text(
                (currentCardIndex + 1).toString() +
                    '/' +
                    policyLength.toString(),
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Kanit',
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildButton(String title, Color color,
      {Function onTap, bool corrected = false}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        height: 35,
        width: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Kanit',
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<dynamic> dialogConfirm() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: CustomAlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 220,
              height: 155,
              // width: MediaQuery.of(context).size.width / 1.3,
              // height: MediaQuery.of(context).size.height / 2.5,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'สมัครสมาชิกเรียบร้อย',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'เราจะทำการส่งเรื่องของท่าน',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    Text(
                      'เพื่อทำการยืนยันต่อไป',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        widget.navTo();
                      },
                      child: Container(
                        height: 35,
                        width: 160,
                        alignment: Alignment.center,
                        // margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF9A1120),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ตกลง',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Kanit',
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // child: //Contents here
            ),
          ),
        );
      },
    );
  }

  nextIndex() {
    if (currentCardIndex != policyLength - 1) {
      setState(() {
        currentCardIndex++;
      });
    } else {
      // TO DO...
    }
  }

  previousIndex() {
    if (currentCardIndex != 0) {
      setState(() {
        currentCardIndex--;
      });
    } else {
      // TO DO...
      Navigator.pop(context);
    }
  }

  sendAcceptedPolicy() async {
    // acceptPolicyList.forEach((e) {
    //   postDio(server + 'm/policy/create', e);
    // });
    Navigator.pop(context);
    // return dialogConfirm();
  }
}
