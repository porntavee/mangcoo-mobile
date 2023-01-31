import 'dart:async';
import 'package:wereward/widget/dialog.dart';
import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';

class OrganizationAddPage extends StatefulWidget {
  @override
  _OrganizationAddPageState createState() => _OrganizationAddPageState();
}

class _OrganizationAddPageState extends State<OrganizationAddPage> {
  Future<dynamic> futureLv0;
  Future<dynamic> futureLv1;
  Future<dynamic> futureLv2;
  Future<dynamic> futureLv3;
  Future<dynamic> futureLv4;

  String lv0 = '';
  String lv1 = '';
  String lv2 = '';
  String lv3 = '';
  String lv4 = '';

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildScaffold();
  }

  _callRead() {
    futureLv0 =
        postDio('${server}organization/category/read', {'category': 'lv0'});
  }

  _buildScaffold() {
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
          isShowLogo: false,
          title: 'หน่วยงานที่รับข้อมูล',
          isCenter: true,
        ),
        body: _buildListView(),
      ),
    );
  }

  _buildListView() {
    return ListView(
      // shrinkWrap: true, // use it
      children: [
        SizedBox(
          height: 20,
        ),
        _widgetText(title: 'ประเภทสมาชิก'),
        _buildLv0(),
        SizedBox(
          height: 12,
        ),
        if (lv0 != '') _widgetText(title: 'เขตการปกครอง'),
        _buildLv1(),
        SizedBox(
          height: 12,
        ),
        if (lv1 != '') _widgetText(title: 'จังหวัด'),
        _buildLv2(),
        SizedBox(
          height: 12,
        ),
        if (lv2 != '') _widgetText(title: 'อำเภอ/เขต'),
        _buildLv3(),
        if (lv3 != '') _widgetText(title: 'ตำบล/แขวง'),
        _buildLv4(),
        SizedBox(
          height: 12,
        ),
        Container(
          margin: EdgeInsets.only(top: 50, bottom: 50),
          padding: EdgeInsets.only(
            left: 50,
            right: 50,
          ),
          child: FlatButton(
            child: Text('บันทึกข้อมูล'),
            color: Color(0xFFFF7514),
            textColor: Colors.white,
            onPressed: () {
              _callSave();
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Color(0xFFFF7514))),
          ),
        )
      ],
    );
  }

  _buildLv0() {
    return FutureBuilder<dynamic>(
      future: futureLv0,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv1 = '';
                    lv2 = '';
                    lv3 = '';
                    lv4 = '';
                    lv0 = lv0 == snapshot.data[index]['code']
                        ? ""
                        : snapshot.data[index]['code'];

                    futureLv1 = Future.value([]);
                    futureLv2 = Future.value([]);
                    futureLv3 = Future.value([]);
                    futureLv4 = Future.value([]);

                    if (lv0 != '')
                      futureLv1 = postDio('${server}organization/category/read',
                          {'category': 'lv1', 'lv0': lv0});
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: lv0 == snapshot.data[index]['code']
                          ? Color(0xFFFF7514)
                          : Colors.white,
                      border: Border.all(color: Color(0xFFFF7514))),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color: lv0 == snapshot.data[index]['code']
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        if (lv0 == snapshot.data[index]['code'])
                          Icon(
                            Icons.check,
                            color: Color(0xFFFFFFFF),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(child: Text('Loading....'));
        }
      },
    );
  }

  _buildLv1() {
    return FutureBuilder<dynamic>(
      future: futureLv1,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv2 = '';
                    lv3 = '';
                    lv4 = '';
                    lv1 = lv1 == snapshot.data[index]['code']
                        ? ""
                        : snapshot.data[index]['code'];
                    futureLv2 = Future.value([]);
                    futureLv3 = Future.value([]);
                    futureLv4 = Future.value([]);

                    if (lv1 != '')
                      futureLv2 = postDio('${server}organization/category/read',
                          {'category': 'lv2', 'lv1': lv1});
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: lv1 == snapshot.data[index]['code']
                          ? Color(0xFFFF7514)
                          : Colors.white,
                      border: Border.all(color: Color(0xFFFF7514))),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color: lv1 == snapshot.data[index]['code']
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        if (lv1 == snapshot.data[index]['code'])
                          Icon(
                            Icons.check,
                            color: Color(0xFFFFFFFF),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv0 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _buildLv2() {
    return FutureBuilder<dynamic>(
      future: futureLv2,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv3 = '';
                    lv4 = '';
                    lv2 = lv2 == snapshot.data[index]['code']
                        ? ""
                        : snapshot.data[index]['code'];

                    futureLv3 = Future.value([]);
                    futureLv4 = Future.value([]);

                    if (lv2 != '')
                      futureLv3 = postDio('${server}organization/category/read',
                          {'category': 'lv3', 'lv2': lv2});
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: lv2 == snapshot.data[index]['code']
                          ? Color(0xFFFF7514)
                          : Colors.white,
                      border: Border.all(color: Color(0xFFFF7514))),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color: lv2 == snapshot.data[index]['code']
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        if (lv2 == snapshot.data[index]['code'])
                          Icon(
                            Icons.check,
                            color: Color(0xFFFFFFFF),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv1 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _buildLv3() {
    return FutureBuilder<dynamic>(
      future: futureLv3,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv4 = '';
                    lv3 = lv3 == snapshot.data[index]['code']
                        ? ''
                        : snapshot.data[index]['code'];

                    futureLv4 = Future.value([]);

                    if (lv3 != '')
                      futureLv4 = postDio('${server}organization/category/read',
                          {'category': 'lv4', 'lv3': lv3});
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: lv3 == snapshot.data[index]['code']
                          ? Color(0xFFFF7514)
                          : Colors.white,
                      border: Border.all(color: Color(0xFFFF7514))),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color: lv3 == snapshot.data[index]['code']
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        if (lv3 == snapshot.data[index]['code'])
                          Icon(
                            Icons.check,
                            color: Color(0xFFFFFFFF),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv2 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _buildLv4() {
    return FutureBuilder<dynamic>(
      future: futureLv4,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv4 = lv4 == snapshot.data[index]['code']
                        ? ''
                        : snapshot.data[index]['code'];
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: lv4 == snapshot.data[index]['code']
                          ? Color(0xFFFF7514)
                          : Colors.white,
                      border: Border.all(color: Color(0xFFFF7514))),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color: lv4 == snapshot.data[index]['code']
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        if (lv4 == snapshot.data[index]['code'])
                          Icon(
                            Icons.check,
                            color: Color(0xFFFFFFFF),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv3 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _callSave() async {
    if (lv0 == '') {
      dialog(context,
          title: 'ไม่สามารถบันทึกข้อมูลได้',
          description: 'กรุณาเลือกหน่วยงาน \nอย่างน้อย 1 รายการ');
    } else {
      await postDio('${server}m/v2/register/organization/create', {
        'lv0': lv0,
        'lv1': lv1,
        'lv2': lv2,
        'lv3': lv3,
        'lv4': lv4,
      });

      Navigator.pop(context, true);
    }
  }

  _widgetText({String title}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
  }
}
