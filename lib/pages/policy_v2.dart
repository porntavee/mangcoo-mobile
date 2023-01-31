import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';

// ignore: must_be_immutable
class PolicyV2Page extends StatefulWidget {
  PolicyV2Page({
    Key key,
    this.category,
    this.navTo,
  }) : super(key: key);

  final String category;
  final Function navTo;

  @override
  _PolicyV2Page createState() => _PolicyV2Page();
}

class _PolicyV2Page extends State<PolicyV2Page> {
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
    _futureModel = postDio(server + "m/policy/read", {
      "skip": 0,
      "limit": 100,
      "category": widget.category,
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
            child: Container(
              alignment: Alignment.center,
              height: double.infinity,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor,
                  ],
                ),
              ),
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     alignment: Alignment.topCenter,
              //     image: AssetImage('assets/images/background_policy.png'),
              //   ),
              // ),
              child: _futureBuilderModel(),
            ),
          ),
          onWillPop: confirmExit,
        ),
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
          // _logicShowCard(snapshot.data, currentCardIndex);
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return _screen([
            {'title': '', 'description': ''}
          ]);
        }
      },
    );
  }

  _screen(dynamic model) {
    policyLength = model.length;
    return Stack(
      // fit: StackFit.expand,
      // alignment: AlignmentDirectional.bottomCenter,
      // shrinkWrap: true,
      // physics: ClampingScrollPhysics(),
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 50,
                  left: 40,
                  right: 40,
                ),
                color: Colors.transparent,
                child: Text(
                  appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Kanit',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            lastPage
                ? _buildListCard(model)
                : _buildCard(model[currentCardIndex])
          ],
        ),
        (currentCardIndex + 1) > 1 || lastPage
            ? Positioned(
                left: 0,
                top: MediaQuery.of(context).padding.top + 5,
                child: Container(
                  // width: 60,
                  // color: Colors.red,
                  // alignment: Alignment.centerRight,
                  child: MaterialButton(
                    minWidth: 29,
                    onPressed: () {
                      backIndex(model);
                    },
                    color: Color(0xFF1B6CA8),
                    textColor: Colors.white,
                    child: Icon(
                      Icons.arrow_back,
                      size: 29,
                    ),
                    shape: CircleBorder(),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  _buildListCard(dynamic model) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.75,
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 40,
      ),
      padding: EdgeInsets.only(bottom: 20),
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
      child: Column(
        children: [
          Expanded(
            child: Container(
              // color: Colors.blueAccent,
              alignment: Alignment.topCenter,
              child: ListView.builder(
                shrinkWrap: true, // 1st add
                physics: ClampingScrollPhysics(),
                itemCount: model.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  model[index]['title'],
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Kanit',
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                              // SizedBox(width: 10),
                              Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xFFEEBA33),
                                ),
                                child: Text(
                                  (index + 1).toString() +
                                      '/' +
                                      policyLength.toString(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: height * 0.4,
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              physics: ClampingScrollPhysics(),
                              controller: scrollController,
                              child: Container(
                                alignment: Alignment.topLeft,
                                // child: HtmlView(
                                //   data: model[index]['description'],
                                //   scrollable:
                                //       false, //false to use MarksownBody and true to use Marksown
                                // ),
                                child: Text(parseHtmlString(
                                    model[index]['description'])),
                              ),
                            ),
                          ),
                        ),
                        _buildButton(
                          acceptPolicyList[index]['isActive']
                              ? 'ยอมรับ'
                              : 'ไม่ยอมรับ',
                          acceptPolicyList[index]['isActive']
                              ? Theme.of(context).primaryColor
                              : Color(0xFF707070),
                          corrected: true,
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          _buildButton(
            'บันทึกข้อมูล',
            Theme.of(context).primaryColor,
            onTap: () {
              sendAcceptedPolicy();
              // dialogConfirm();
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  _buildCard(dynamic model) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.75,
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 40,
      ),
      padding: EdgeInsets.all(20),
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
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    model['title'],
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Kanit',
                    ),
                    maxLines: 3,
                  ),
                ),
                SizedBox(width: 10),
                Container(
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
                )
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              // isAlwaysShown: false,
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  alignment: Alignment.topLeft,
                  // child: HtmlView(
                  //   data: model['description'],
                  //   scrollable:
                  //       false, //false to use MarksownBody and true to use Marksown
                  // ),
                  child: Text(parseHtmlString(model['description'])),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildButton(
            'ยอมรับ',
            Theme.of(context).primaryColor,
            onTap: () {
              nextIndex(model, true);
            },
          ),
          SizedBox(height: 15),
          _buildButton(
            'ไม่ยอมรับ',
            Color(0xFF707070),
            onTap: () {
              nextIndex(model, false);
            },
          ),
          SizedBox(height: 20),
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
        height: 40,
        width: 285,
        alignment: Alignment.center,
        // margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: Row(
          children: [
            SizedBox(width: 40),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Kanit',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: corrected
                  ? Image.asset(
                      'assets/images/correct.png',
                      height: 15,
                      width: 15,
                    )
                  : null,
            )
          ],
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
          child: CustomAlertDialog2(
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
                        decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
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

  nextIndex(dynamic model, bool accepted) {
    scrollController.jumpTo(0);
    if (currentCardIndex == policyLength - 1) {
      setState(() {
        lastPage = true;
        acceptPolicyList.add({
          'index': currentCardIndex,
          'reference': model['code'],
          'isActive': accepted
        });
      });
    } else {
      setState(() {
        acceptPolicyList.add({
          'index': currentCardIndex,
          'reference': model['code'],
          'isActive': accepted
        });
        currentCardIndex++;
      });
    }
  }

  backIndex(dynamic model) {
    scrollController.jumpTo(0);
    setState(() {
      if (lastPage) {
        lastPage = false;
        acceptPolicyList
            .removeWhere((item) => item['index'] == currentCardIndex);
      } else {
        currentCardIndex--;
        acceptPolicyList
            .removeWhere((item) => item['index'] == currentCardIndex);
      }
    });
  }

  sendAcceptedPolicy() async {
    acceptPolicyList.forEach((e) {
      postDio(server + 'm/policy/create', e);
    });
    return dialogConfirm();
  }
}
