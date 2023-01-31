import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/text_form_field.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  final String username;
  final String password;
  final String facebookID;
  final String appleID;
  final String googleID;
  final String lineID;
  final String email;
  final String imageUrl;
  final String category;
  final String prefixName;
  final String firstName;
  final String lastName;
  final bool isShowStep1 = true;
  final bool isShowStep2 = false;

  RegisterPage({
    Key key,
    this.username: "",
    this.password: "",
    this.facebookID: "",
    this.appleID: "",
    this.googleID: "",
    this.lineID: "",
    this.email: "",
    this.imageUrl: "",
    this.category: "",
    this.prefixName: "",
    this.firstName: "",
    this.lastName: "",
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final storage = new FlutterSecureStorage();

  String _username;
  // String _password;
  // String _facebookID;
  // String _appleID;
  // String _googleID;
  // String _lineID;
  // String _email;
  // String _imageUrl;
  // String _category;
  // String _prefixName;
  // String _firstName;
  // String _lastName;

  // bool _isLoginSocial = false;
  // bool _isLoginSocialHaveEmail = false;
  bool _isShowStep1 = true;
  bool _isShowStep2 = false;
  bool _checkedValue = false;
  // Register _register;
  List<dynamic> _dataPolicy = [];

  final _formKey = GlobalKey<FormState>();

  // List<String> _prefixNames = ['นาย', 'นาง', 'นางสาว']; // Option 2
  // String _selectedPrefixName;

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtEmail = TextEditingController();
  final txtPrefixName = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  Future<dynamic> _futureModel;

  ScrollController scrollController = new ScrollController();

  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void initState() {
    _callRead();

    var now = new DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
      // _username = widget.username;
      // _password = widget.password;
      // _facebookID = widget.facebookID;
      // _appleID = widget.appleID;
      // _googleID = widget.googleID;
      // _lineID = widget.lineID;
      // _email = widget.email;
      // _imageUrl = widget.imageUrl;
      // _category = widget.category;
      // _prefixName = widget.prefixName;
      // _firstName = widget.firstName;
      // _lastName = widget.lastName;

      // txtUsername.text = widget.username;
      // futureModel = readPolicy();
    });

    // if (widget.category != 'guest') {
    //   setState(() {
    //     _isLoginSocial = true;
    //   });
    // }
    // if (widget.username != '' && widget.username != null) {
    //   setState(() {
    //     _isLoginSocialHaveEmail = true;
    //   });
    // }

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtUsername.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, goBack, title: 'สมัครสมาชิก'),
      backgroundColor: Colors.white,
      body: ListView(
        controller: scrollController,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.all(15.0),
        children: [
          // myWizard(),
          // card(),
          formContentStep2()
        ],
      ),
      // body: FutureBuilder<dynamic>(
      //   future: _futureModel,
      //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      //     if (snapshot.hasData) {
      //       return ListView(
      //         controller: scrollController,
      //         shrinkWrap: true,
      //         physics: ClampingScrollPhysics(),
      //         padding: const EdgeInsets.all(15.0),
      //         children: [
      //           // myWizard(),
      //           // card(),
      //           formContentStep2()
      //         ],
      //       );
      //     } else if (snapshot.hasError) {
      //       return Container();
      //     } else {
      //       return Container();
      //     }
      //   },
      // ),
    );
  }

  _callRead() {
    _futureModel = postDio('${server}m/policy/read', {
      'username': this._username,
      'category': 'register',
    });
  }

  Future<dynamic> readPolicy() async {
    final result = await postObjectData('m/policy/read', {
      'username': this._username,
      'category': 'register',
    });

    if (result['status'] == 'S') {
      if (result['objectData'].length > 0) {
        setState(() {
          _dataPolicy = [..._dataPolicy, ...result['objectData']];
        });
      }
    }
  }

  Future<Null> checkValueStep1() async {
    if (_checkedValue) {
      setState(() {
        _isShowStep1 = false;
        _isShowStep2 = true;
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      });
    } else {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: new Text(
                'กรุณาติ้ก ยอมรับข้อตกลงเงื่อนไข',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(" "),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFF7514),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<dynamic> submitRegister() async {
    // Pattern pattern =
    //     r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    // RegExp regex = new RegExp(pattern);
    // if (!(regex.hasMatch(txtEmail.text))) {
    //   return showDialog(
    //       barrierDismissible: false,
    //       context: context,
    //       builder: (BuildContext context) {
    //         return WillPopScope(
    //           onWillPop: () {
    //             return Future.value(false);
    //           },
    //           child: CupertinoAlertDialog(
    //             title: new Text(
    //               'รูปแบบอีเมลไม่ถูกต้อง',
    //               style: TextStyle(
    //                 fontSize: 16,
    //                 fontFamily: 'Kanit',
    //                 color: Colors.black,
    //                 fontWeight: FontWeight.normal,
    //               ),
    //             ),
    //             content: Text(" "),
    //             actions: [
    //               CupertinoDialogAction(
    //                 isDefaultAction: true,
    //                 child: new Text(
    //                   "ตกลง",
    //                   style: TextStyle(
    //                     fontSize: 13,
    //                     fontFamily: 'Kanit',
    //                     color: Color(0xFFFF7514),
    //                     fontWeight: FontWeight.normal,
    //                   ),
    //                 ),
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //               ),
    //             ],
    //           ),
    //         );
    //       });
    // }

    final result = await postLoginRegister('m/Register/create', {
      'username': txtPhone.text,
      'password': txtPassword.text,
      'facebookID': "",
      'appleID': "",
      'googleID': "",
      'lineID': "",
      'email': txtEmail.text,
      'imageUrl': "",
      'category': "guest",
      'prefixName': txtPrefixName.text,
      'firstName': txtFirstName.text,
      'lastName': txtLastName.text,
      'phone': txtPhone.text,
      'birthDay': "",
      // 'birthDay': DateFormat("yyyyMMdd").format(
      //   DateTime(
      //     _selectedYear,
      //     _selectedMonth,
      //     _selectedDay,
      //   ),
      // ),
      'status': "N",
      'platform': Platform.operatingSystem.toString(),
      'countUnit': "[]"
    });

    if (result.status == 'S') {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => LoginPage(),
      //   ),
      // );

      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: CupertinoAlertDialog(
                title: new Text(
                  'ลงทะเบียนเรียบร้อยแล้ว',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                content: Text(" "),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: new Text(
                      "ตกลง",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        color: Color(0xFFFF7514),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          });
    } else {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: CupertinoAlertDialog(
                title: new Text(
                  result.message,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                content: Text(" "),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: new Text(
                      "ตกลง",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        color: Color(0xFFFF7514),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          });
    }
  }

  dialogOpenPickerDate() {
    DatePicker.showDatePicker(
      context,
      theme: DatePickerTheme(
        containerHeight: 210.0,
        itemStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFFF7514),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        doneStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFFF7514),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        cancelStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFFF7514),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
      ),
      showTitleActions: true,
      minTime: DateTime(1800, 1, 1),
      maxTime: DateTime(year, month, day),
      onConfirm: (date) {
        setState(
          () {
            _selectedYear = date.year;
            _selectedMonth = date.month;
            _selectedDay = date.day;
            txtDate.value = TextEditingValue(
              text: DateFormat("dd-MM-yyyy").format(date),
            );
          },
        );
      },
      currentTime: DateTime(
        _selectedYear,
        _selectedMonth,
        _selectedDay,
      ),
      locale: LocaleType.th,
    );
  }

  myWizard() {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 0.0,
            left: 30.0,
            right: 30.0,
            bottom: 0.0,
          ),
          child: Column(
            children: <Widget>[
              new Row(
                children: [
                  new Column(
                    children: <Widget>[
                      new Container(
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Text(
                          '1',
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            fontSize: 20.0,
                            color: _isShowStep1 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                          ),
                        ),
                        decoration: new BoxDecoration(
                          color: _isShowStep1
                              ? Color(0xFFFFC324)
                              : Color(0xFFFFFFFF),
                          borderRadius: new BorderRadius.all(
                            new Radius.circular(25.0),
                          ),
                          border: new Border.all(
                            color: Color(0xFFFFC324),
                            width: 2.0,
                          ),
                        ),
                      ),
                      Text(
                        'ข้อตกลง',
                        style: new TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        height: 2.0,
                        color: Color(0xFFFFC324),
                      ),
                    ),
                  ),
                  new Column(
                    children: <Widget>[
                      new Container(
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Text(
                          '2',
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            fontSize: 20.0,
                            color: _isShowStep2 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                          ),
                        ),
                        decoration: new BoxDecoration(
                          color: _isShowStep2
                              ? Color(0xFFFFC324)
                              : Color(0xFFFFFFFF),
                          borderRadius: new BorderRadius.all(
                            new Radius.circular(25.0),
                          ),
                          border: new Border.all(
                            color: Color(0xFFFFC324),
                            width: 2.0,
                          ),
                        ),
                      ),
                      Text(
                        'ข้อมูลส่วนตัว',
                        style: new TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  card() {
    return Card(
      color: Colors.white,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(15.0),
      // ),
      // elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: formContentStep2(),
      ),
      // child: _isShowStep1 ? formContentStep1() : formContentStep2()),
    );
  }

  formContentStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var item in _dataPolicy)
          new Html(
            data: item['description'].toString(),
            onLinkTap: (String url, RenderContext context,
                Map<String, String> attributes, element) {
              launch(url);
              // open url in a webview
            },
          ),
        new Container(
          alignment: Alignment.center,
          child: CheckboxListTile(
            activeColor: Theme.of(context).primaryColor,
            title: Text(
              "ฉันยอมรับข้อตกลงในการบริการ",
              style: new TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
            value: _checkedValue,
            onChanged: (newValue) {
              setState(() {
                _checkedValue = newValue;
              });
            },
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 0.0,
          ),
          child: new RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Color(0xFFFFC324),
              ),
            ),
            onPressed: () {
              checkValueStep1();
            },
            color: Color(0xFFFFC324),
            textColor: Colors.white,
            child: Text(
              "ถัดไป >",
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
          ),
        ),
      ],
    );
  }

  formContentStep2() {
    return (Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   'ข้อมูลผู้ใช้งาน',
          //   style: TextStyle(
          //     fontSize: 18.00,
          //     fontFamily: 'Kanit',
          //     fontWeight: FontWeight.w500,
          //     // color: Color(0xFFBC0611),
          //   ),
          // ),
          // SizedBox(height: 5.0),
          labelTextFormField('* หมายเลขโทรศัพท์'),
          textFormField(
            txtPhone,
            null,
            'กรุณากรอกหมายเลขโทรศัพท์',
            'หมายเลขโทรศัพท์',
            true,
            false,
            false,
            isPattern: true,
          ),
          // labelTextFormField('* รหัสผ่าน'),
          labelTextFormFieldPasswordOldNew('* รหัสผ่าน', true),
          textFormField(
            txtPassword,
            null,
            'รหัสผ่าน',
            'รหัสผ่าน',
            true,
            true,
            false,
            isPattern: true,
          ),
          labelTextFormField('* ยืนยันรหัสผ่าน'),
          TextFormField(
            obscureText: true,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              fontSize: 15.00,
            ),
            decoration: InputDecoration(
              // filled: true,
              // fillColor: enabled ? Color(0xFF373737) : Color(0xFF707070),
              contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              hintText: 'ยืนยันรหัสผ่าน',
              hintStyle: TextStyle(
                // color: Colors.white70,
                fontFamily: 'Kanit',
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF707070)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            // decoration: InputDecoration(
            //   hintText: 'ยืนยันรหัสผ่าน',
            //   filled: true,
            //   fillColor: Color(0xFFC5DAFC),
            //   contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
            //   border: OutlineInputBorder(
            //     borderRadius: BorderRadius.circular(10.0),
            //     borderSide: BorderSide.none,
            //   ),
            //   errorStyle: TextStyle(
            //     fontWeight: FontWeight.normal,
            //     fontFamily: 'Kanit',
            //     fontSize: 10.0,
            //   ),
            // ),
            validator: (model) {
              if (model.isEmpty) {
                return 'กรุณากรอกข้อมูล. $model';
              }

              if (model != txtPassword.text)
                return 'กรุณากรอกรหัสผ่านให้ตรงกัน.';
            },
            controller: txtConPassword,
            enabled: true,
          ),

          // textFormField(
          //   txtConPassword,
          //   txtPassword.text,
          //   'ยืนยันรหัสผ่าน',
          //   'ยืนยันรหัสผ่าน',
          //   true,
          //   true,
          //   false,
          // ),
          // SizedBox(height: 15.0),
          // Text(
          //   'ข้อมูลส่วนตัว',
          //   style: TextStyle(
          //     fontSize: 18.00,
          //     fontFamily: 'Kanit',
          //     fontWeight: FontWeight.w500,
          //     // color: Color(0xFFBC0611),
          //   ),
          // ),
          // SizedBox(height: 5.0),

          // labelTextFormField('คำนำหน้า'),
          // textFormField(
          //   txtPrefixName,
          //   null,
          //   'คำนำหน้า',
          //   'คำนำหน้า',
          //   true,
          //   false,
          //   false,
          // ),
          // new Container(
          //   width: 5000.0,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 5,
          //     vertical: 0,
          //   ),
          //   decoration: BoxDecoration(
          //     color: Color(0xFFC5DAFC),
          //     borderRadius: BorderRadius.circular(
          //       10,
          //     ),
          //   ),
          //   // child: DropdownButtonHideUnderline(
          //   child: DropdownButtonFormField(
          //     decoration: InputDecoration(
          //       errorStyle: TextStyle(
          //         fontWeight: FontWeight.normal,
          //         fontFamily: 'Kanit',
          //         fontSize: 10.0,
          //       ),
          //       enabledBorder: UnderlineInputBorder(
          //         borderSide: BorderSide(
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //     validator: (value) =>
          //         value == '' || value == null ? 'กรุณาเลือกคำนำหน้า' : null,
          //     hint: Text(
          //       'กรุณาเลือกคำนำหน้า',
          //       style: TextStyle(
          //         fontSize: 15.00,
          //         fontFamily: 'Kanit',
          //       ),
          //     ),
          //     value: _selectedPrefixName,
          //     onChanged: (newValue) {
          //       setState(() {
          //         _selectedPrefixName = newValue;
          //       });
          //     },
          //     items: _prefixNames.map((prefixName) {
          //       return DropdownMenuItem(
          //         child: new Text(
          //           prefixName,
          //           style: TextStyle(
          //             fontSize: 15.00,
          //             fontFamily: 'Kanit',
          //             color: Color(
          //               0xFFFF7514,
          //             ),
          //           ),
          //         ),
          //         value: prefixName,
          //       );
          //     }).toList(),
          //   ),
          //   // ),
          // ),
          labelTextFormField('ชื่อ'),
          textFormField(
            txtFirstName,
            null,
            'ชื่อ',
            'ชื่อ',
            true,
            false,
            false,
          ),
          labelTextFormField('นามสกุล'),
          textFormField(
            txtLastName,
            null,
            'นามสกุล',
            'นามสกุล',
            true,
            false,
            false,
          ),
          // labelTextFormField('อีเมล'),
          // TextFormField(
          //   controller: txtEmail,
          //   style: TextStyle(
          //     color: Color(0xFF000070),
          //     fontWeight: FontWeight.normal,
          //     fontFamily: 'Kanit',
          //     fontSize: 15.00,
          //   ),
          //   decoration: InputDecoration(
          //     filled: true,
          //     fillColor: Color(0xFFC5DAFC),
          //     contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          //     hintText: 'อีเมล',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10.0),
          //       borderSide: BorderSide.none,
          //     ),
          //     errorStyle: TextStyle(
          //       fontWeight: FontWeight.normal,
          //       fontFamily: 'Kanit',
          //       fontSize: 10.0,
          //     ),
          //   ),
          //   // ignore: missing_return
          //   validator: (param) {
          //     if (param != "" && param != null) {
          //       Pattern pattern =
          //           r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
          //       RegExp regex = new RegExp(pattern);
          //       if (!regex.hasMatch(param)) {
          //         return 'กรุณากรอกรูปแบบอีเมลให้ถูกต้อง.';
          //       }
          //     }
          //   },
          // ),
          // textFormFieldNoValidator(txtEmail, 'อีเมล', true, true),
          // labelTextFormField('วันเดือนปีเกิด'),
          // GestureDetector(
          //   onTap: () => dialogOpenPickerDate(),
          //   child: AbsorbPointer(
          //     child: TextFormField(
          //       controller: txtDate,
          //       style: TextStyle(
          //         color: Color(0xFFFF7514),
          //         fontWeight: FontWeight.normal,
          //         fontFamily: 'Kanit',
          //         fontSize: 15.0,
          //       ),
          //       decoration: InputDecoration(
          //         filled: true,
          //         fillColor: Color(0xFFC5DAFC),
          //         contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          //         hintText: "วันเดือนปีเกิด",
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //           borderSide: BorderSide.none,
          //         ),
          //         errorStyle: TextStyle(
          //           fontWeight: FontWeight.normal,
          //           fontFamily: 'Kanit',
          //           fontSize: 10.0,
          //         ),
          //       ),
          //       // validator: (model) {
          //       //   if (model.isEmpty) {
          //       //     return 'กรุณากรอกวันเดือนปีเกิด.';
          //       //   }
          //       // },
          //     ),
          //   ),
          // ),
          // labelTextFormField('* เบอร์โทรศัพท์ (10 หลัก)'),
          // textFormPhoneField(
          //   txtPhone,
          //   'เบอร์โทรศัพท์ (10 หลัก)',
          //   'เบอร์โทรศัพท์ (10 หลัก)',
          //   true,
          //   true,
          // ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              margin: EdgeInsets.only(top: 15.0, bottom: 10.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(5.0),
                color: Theme.of(context).primaryColor,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 40,
                  onPressed: () {
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();
                      submitRegister();
                    }
                  },
                  child: new Text(
                    'สมัครสมาชิก',
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => LoginPage(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
  }
}
