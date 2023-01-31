import 'package:wereward/pages/reporter/reporter_list_category_disaster_vertical.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/component/carousel_form.dart';
import 'package:wereward/component/link_url_in.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:intl/intl.dart';

class ReporterListCategoryDisaster extends StatefulWidget {
  ReporterListCategoryDisaster({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ReporterListCategoryDisaster createState() =>
      _ReporterListCategoryDisaster();
}

class _ReporterListCategoryDisaster
    extends State<ReporterListCategoryDisaster> {
  final storage = new FlutterSecureStorage();

  ReporterListCategoryDisasterVertical reporter;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch;
  String category;
  bool showFilter = false;
  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategoryReporter;
  List<dynamic> _itemStatus = [
    {'title': 'ทั้งหมด', 'code': ''},
    {'title': 'รับแจ้งใหม่', 'code': 'N'},
    {'title': 'อยู่ระหว่างดำเนินการ', 'code': 'P'},
    {'title': 'ดำเนินการแล้วเสร็จ', 'code': 'A'},
    {'title': 'ยกเลิกแจ้งเหตุ', 'code': 'C'},
  ];
  TextEditingController _startDate = TextEditingController();
  TextEditingController _endDate = TextEditingController();
  TextEditingController _status = TextEditingController();
  DateTime selectedDate = DateTime.now();
  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _status.dispose();
    showFilter = false;
    super.dispose();
  }

  @override
  void initState() {
    _callread();

    super.initState();
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
          isShowLogo: false,
          title: widget.title,
          isShowButtonFilter: true, // เพื่อให้โชว์ปุ่มขวาบน
          isButtonFilter: showFilter,
          callBackClickButtonCalendar: () {
            setState(() {
              showFilter = !showFilter;
            });
          },
          // isButtonRight: true,
          // rightButton: () => _handleClickMe(),
          // menu: 'reporter',
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: Stack(children: [
            ListView(physics: ScrollPhysics(), shrinkWrap: true, children: [
              CarouselBanner(
                model: _futureBanner,
                url: 'reporter/',
              ),
              // ),
              SizedBox(height: 10),
              ReporterListCategoryDisasterVertical(
                site: "DDPM",
                model: _futureCategoryReporter,
                title: "",
                url: '${reporterCategoryApi}read',
              ),
            ]),
            showFilter
                ? Container(
                    color: Colors.white.withOpacity(0.9),
                    height: 350,
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 30),
                    child: ListView(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          _widgetTextTitileHeader(title: 'ช่วงวันที่'),
                          SizedBox(height: 10),
                          new Padding(
                            padding: EdgeInsets.only(left: 50, right: 50),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                new TextEditingController().clear();
                                dialogOpenPickerDate(start: true);
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _startDate,
                                  style: TextStyle(
                                    color: Color(0xFF000070),
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Kanit',
                                    fontSize: 15.0,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFFC5DAFC),
                                    contentPadding:
                                        EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                                    hintText: "วันที่เริ่ม",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Kanit',
                                      fontSize: 10.0,
                                    ),
                                  ),
                                  // validator: (model) {
                                  //   if (model.isEmpty) {
                                  //     return 'กรุณากรอกวันเดือนปีเกิด.';
                                  //   }
                                  // },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          new Padding(
                            padding: EdgeInsets.only(left: 50, right: 50),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                new TextEditingController().clear();
                                dialogOpenPickerDate(end: true);
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _endDate,
                                  style: TextStyle(
                                    color: Color(0xFF000070),
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Kanit',
                                    fontSize: 15.0,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFFC5DAFC),
                                    contentPadding:
                                        EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                                    hintText: "วันสิ้นสุด",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Kanit',
                                      fontSize: 10.0,
                                    ),
                                  ),
                                  // validator: (model) {
                                  //   if (model.isEmpty) {
                                  //     return 'กรุณากรอกวันเดือนปีเกิด.';
                                  //   }
                                  // },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          _widgetTextTitileHeader(title: 'สถานะ'),
                          SizedBox(height: 10),
                          new Padding(
                            padding: EdgeInsets.only(left: 50, right: 50),
                            child: Container(
                              width: 10.0,
                              padding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFC5DAFC),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Kanit',
                                    fontSize: 10.0,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == '' || value == null
                                        ? 'กรุณาสถานะ'
                                        : null,
                                hint: Text(
                                  _status.text == ''
                                      ? 'สถานะ'
                                      : _itemStatus.firstWhere((c) =>
                                          c['code'] == _status.text)['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  new TextEditingController().clear();
                                },
                                onChanged: (newValue) {
                                  setState(() {
                                    _status.text = newValue;
                                  });
                                },
                                items: _itemStatus.map((item) {
                                  return DropdownMenuItem(
                                    child: new Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontSize: 15.00,
                                        fontFamily: 'Kanit',
                                        color: Color(
                                          0xFF000070,
                                        ),
                                      ),
                                    ),
                                    value: item['code'],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Color(0xFFFF7514))),
                                color: Color(0xFFFFFFFF),
                                onPressed: () {
                                  setState(() {
                                    _startDate.text = '';
                                    _endDate.text = '';
                                    _status.text = '';
                                    showFilter = false;
                                  });
                                },
                                child: Text(
                                  'ยกเลิก',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Color(0xFFFF7514))),
                                color: Color(0xFFFF7514),
                                onPressed: () {
                                  _callread();
                                },
                                child: Text(
                                  'ตกลง',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  )
                : Container(),
          ]),
        ),
      ),
    );
  }

  _callread() {
    _futureCategoryReporter = postDio('${reporterCategoryApi}read', {
      'limit': 50,
      'startDate':
          _startDate.text == '' ? '' : dateToDateString(_startDate.text),
      'endDate': _endDate.text == '' ? '' : dateToDateString(_endDate.text),
      'status': _status.text
    });
    _futureBanner = postDio('${reporterBannerApi}read', {'limit': 50});
    setState(() {
      showFilter = false;
    });
  }

  _widgetTextTitileHeader({String title}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
  }

  dialogOpenPickerDate({bool start = false, bool end = false}) {
    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
          containerHeight: 210.0,
          itemStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF9A1120),
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
          doneStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF9A1120),
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
          cancelStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF9A1120),
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
        ),
        showTitleActions: true,
        minTime: DateTime(1800, 1, 1),
        maxTime: DateTime(new DateTime.now().year, new DateTime.now().month,
            new DateTime.now().day), onConfirm: (date) {
      setState(
        () {
          if (start)
            _startDate.value = TextEditingValue(
              text: DateFormat("dd-MM-yyyy").format(date),
            );
          if (end)
            _endDate.value = TextEditingValue(
              text: DateFormat("dd-MM-yyyy").format(date),
            );
        },
      );
    },
        currentTime: DateTime(
          new DateTime.now().year,
          new DateTime.now().month,
          new DateTime.now().day,
        ),
        locale: LocaleType.th);
  }
}
