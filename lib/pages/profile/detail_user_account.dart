import 'dart:convert';
import 'dart:io';
import 'package:wereward/widget/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/text_form_field.dart';

import '../../home_mart.dart';

class DetailUserAccountPage extends StatefulWidget {
  @override
  _DetailUserAccountPageState createState() => _DetailUserAccountPageState();
}

class _DetailUserAccountPageState extends State<DetailUserAccountPage> {
  final storage = new FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  String _imageUrl;
  String _code;

  final _formKey = GlobalKey<FormState>();

  List<String> _itemPrefixName = ['นาย', 'นาง', 'นางสาว']; // Option 2
  String _selectedPrefixName;

  List<dynamic> _itemSex = [
    {'title': 'ชาย', 'code': 'ชาย'},
    {'title': 'หญิง', 'code': 'หญิง'},
    {'title': 'ไม่ระบุเพศ', 'code': ''}
  ];
  String _selectedSex;

  List<dynamic> _itemProvince = [];
  String _selectedProvince;

  List<dynamic> _itemDistrict = [];
  String _selectedDistrict;

  List<dynamic> _itemSubDistrict = [];
  String _selectedSubDistrict;

  List<dynamic> _itemPostalCode = [];
  String _selectedPostalCode;

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtPrefixName = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtUsername = TextEditingController();
  final txtIdCard = TextEditingController();
  final txtLineID = TextEditingController();
  final txtOfficerCode = TextEditingController();
  final txtAddress = TextEditingController();
  final txtMoo = TextEditingController();
  final txtSoi = TextEditingController();
  final txtRoad = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  Future<dynamic> futureModel;

  ScrollController scrollController = new ScrollController();

  XFile _image;

  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  int year = 0;
  int month = 0;
  int day = 0;

  String _categorySocial = '';
  String _imageUrlSocial = '';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    txtPhone.dispose();
    txtDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    futureModel = getUser();

    scrollController = ScrollController();
    var now = new DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    });
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
        appBar: header2(
          context,
          title: 'บัญชีผู้ใช้งาน',
          // isShowLogo: false,
          // isCenter: true,
        ),
        backgroundColor: Colors.white,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FutureBuilder<dynamic>(
            future: futureModel,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Container(
                  color: Colors.white,
                  child: dialogFail(context),
                ));
              } else {
                return Container(
                  height: double.infinity,
                  // padding: EdgeInsets.only(left: 30),
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: [
                      // Stack(
                      //   children: [
                      //     Container(
                      //       decoration: BoxDecoration(
                      //         image: DecorationImage(
                      //           fit: BoxFit.fill,
                      //           image: AssetImage(
                      //             'assets/images/background_user_info.png',
                      //           ),
                      //         ),
                      //       ),
                      //       height: 150.0,
                      //     ),
                      //     Container(
                      //       height: 150.0,
                      //       decoration: BoxDecoration(
                      //         image: DecorationImage(
                      //           fit: BoxFit.fill,
                      //           image: AssetImage(
                      //             'assets/images/background_user_info_color.png',
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Center(
                      //       child: Container(
                      //         width: 90.0,
                      //         height: 90.0,
                      //         margin: EdgeInsets.only(top: 30.0),
                      //         padding: EdgeInsets.all(
                      //             _imageUrl != null && _imageUrl != ''
                      //                 ? 0.0
                      //                 : 5.0),
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(45),
                      //             color: Colors.white70),
                      //         child: GestureDetector(
                      //           onTap: () {
                      //             _showPickerImage(context);
                      //           },
                      //           child: _imageUrl != null && _imageUrl != ''
                      //               ? CircleAvatar(
                      //                   backgroundColor: Colors.black,
                      //                   backgroundImage:
                      //                       _imageUrl != null && _imageUrl != ''
                      //                           ? NetworkImage(_imageUrl)
                      //                           : null,
                      //                 )
                      //               : Container(
                      //                   padding: EdgeInsets.all(10.0),
                      //                   child: Image.asset(
                      //                     'assets/images/user_not_found.png',
                      //                     color: Theme.of(context).accentColor,
                      //                   ),
                      //                 ),
                      //         ),
                      //       ),
                      //     ),
                      //     Center(
                      //       child: Container(
                      //         width: 25.0,
                      //         height: 25.0,
                      //         margin: EdgeInsets.only(top: 90.0, left: 70.0),
                      //         child: Padding(
                      //           padding: EdgeInsets.all(0.0),
                      //           child: DecoratedBox(
                      //             decoration: ShapeDecoration(
                      //               shape: CircleBorder(),
                      //               image: DecorationImage(
                      //                 fit: BoxFit.contain,
                      //                 alignment: Alignment.center,
                      //                 image:
                      //                     AssetImage("assets/images/camera.png"),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Container(
                        color: Colors.transparent,
                        child: contentCard(),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<dynamic> getProvince() async {
    final result = await postObjectData("route/province/read", {});
    if (result['status'] == 'S') {
      setState(() {
        _itemProvince = result['objectData'];
      });
    }
  }

  Future<dynamic> getDistrict() async {
    final result = await postObjectData("route/district/read", {
      'province': _selectedProvince,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemDistrict = result['objectData'];
      });
    }
  }

  Future<dynamic> getSubDistrict() async {
    final result = await postObjectData("route/tambon/read", {
      'province': _selectedProvince,
      'district': _selectedDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemSubDistrict = result['objectData'];
      });
    }
  }

  Future<dynamic> getPostalCode() async {
    final result = await postObjectData("route/postcode/read", {
      'tambon': _selectedSubDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemPostalCode = result['objectData'];
      });
    }
  }

  bool isValidDate(String input) {
    try {
      final date = DateTime.parse(input);
      final originalFormatString = toOriginalFormatString(date);
      return input == originalFormatString;
    } catch (e) {
      return false;
    }
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  Future<dynamic> getUser() async {
    var categorySocial = await storage.read(key: 'categorySocial');
    if (categorySocial != '' && categorySocial != null)
      setState(() {
        _categorySocial = categorySocial;
      });

    var imageUrlSocial = await storage.read(key: 'imageUrlSocial');
    if (imageUrlSocial != '' && imageUrlSocial != null)
      setState(() {
        _imageUrlSocial = imageUrlSocial;
      });

    var profileCode = await storage.read(key: 'profileCode10');
    // print('----profileCode-----$profileCode');
    if (profileCode != '') {
      final result =
          await postObjectData("m/Register/read", {'code': profileCode});

      // print('----status-----${result['status']}');
      // print('----objectData-----${result['objectData'].toString()}');
      if (result['status'] == 'S') {
        await storage.write(
          key: 'dataUserLoginDDPM',
          value: jsonEncode(result['objectData'][0]),
        );

        // print('----birthDay-----${result['objectData'][0]['birthDay']}');
        if (result['objectData'][0]['birthDay'] != '' &&
            result['objectData'][0]['birthDay'] != null) {
          if (isValidDate(result['objectData'][0]['birthDay'])) {
            var date = result['objectData'][0]['birthDay'];
            var year = date.substring(0, 4);
            var month = date.substring(4, 6);
            var day = date.substring(6, 8);
            DateTime todayDate = DateTime.parse(year + '-' + month + '-' + day);
            setState(() {
              _selectedYear = todayDate.year;
              _selectedMonth = todayDate.month;
              _selectedDay = todayDate.day;
              txtDate.text = DateFormat("dd-MM-yyyy").format(todayDate);
            });
          }
        }

        setState(() {
          _imageUrl = result['objectData'][0]['imageUrl'] ?? '';
          txtFirstName.text = result['objectData'][0]['firstName'] ?? '';
          txtLastName.text = result['objectData'][0]['lastName'] ?? '';
          txtEmail.text = result['objectData'][0]['email'] ?? '';
          txtPhone.text = result['objectData'][0]['phone'] ?? '';
          _selectedPrefixName = result['objectData'][0]['prefixName'];
          _code = result['objectData'][0]['code'] ?? '';
          txtPhone.text = result['objectData'][0]['phone'] ?? '';
          txtUsername.text = result['objectData'][0]['username'] ?? '';
          txtIdCard.text = result['objectData'][0]['idcard'] ?? '';
          txtLineID.text = result['objectData'][0]['lineID'] ?? '';
          txtOfficerCode.text = result['objectData'][0]['officerCode'] ?? '';
          txtAddress.text = result['objectData'][0]['address'] ?? '';
          txtMoo.text = result['objectData'][0]['moo'] ?? '';
          txtSoi.text = result['objectData'][0]['soi'] ?? '';
          txtRoad.text = result['objectData'][0]['road'] ?? '';
          txtPrefixName.text = result['objectData'][0]['prefixName'] ?? '';

          _selectedProvince = result['objectData'][0]['provinceCode'] ?? '';
          _selectedDistrict = result['objectData'][0]['amphoeCode'] ?? '';
          _selectedSubDistrict = result['objectData'][0]['tambonCode'] ?? '';
          _selectedPostalCode = result['objectData'][0]['postnoCode'] ?? '';
          _selectedSex = result['objectData'][0]['sex'] ?? '';
        });
      }
      if (_selectedProvince != '') {
        getProvince();
        getDistrict();
        getSubDistrict();
        // setState(() {
        //   futureModel =
        getPostalCode();
        // });
      } else {
        // setState(() {
        //   futureModel =
        getProvince();
        // });
      }
    }
  }

  Future<dynamic> submitUpdateUser() async {
    print(
        '---------------------------$_selectedProvince----------------------------');

    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value);
    user['imageUrl'] = _imageUrl ?? '';
    // user['prefixName'] = _selectedPrefixName ?? '';
    user['prefixName'] = txtPrefixName.text ?? '';
    user['firstName'] = txtFirstName.text ?? '';
    user['lastName'] = txtLastName.text ?? '';
    user['email'] = txtEmail.text ?? '';
    user['phone'] = txtPhone.text ?? '';

    user['birthDay'] = DateFormat("yyyyMMdd").format(
      DateTime(
        _selectedYear,
        _selectedMonth,
        _selectedDay,
      ),
    );
    user['sex'] = _selectedSex ?? '';
    user['address'] = txtAddress.text ?? '';
    user['soi'] = txtSoi.text ?? '';
    user['moo'] = txtMoo.text ?? '';
    user['road'] = txtRoad.text ?? '';
    user['tambon'] = '';
    user['amphoe'] = '';
    user['province'] = '';
    user['postno'] = '';
    user['tambonCode'] = _selectedSubDistrict ?? '';
    user['amphoeCode'] = _selectedDistrict ?? '';
    user['provinceCode'] = _selectedProvince ?? '';
    user['postnoCode'] = _selectedPostalCode ?? '';
    user['idcard'] = txtIdCard.text ?? '';
    user['officerCode'] = txtOfficerCode.text ?? '';
    user['linkAccount'] =
        user['linkAccount'] != null ? user['linkAccount'] : '';
    user['appleID'] = user['appleID'] != null ? user['appleID'] : "";

    final result = await postObjectData('m/v2/Register/update', user);

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataUserLoginDDPM',
        value: jsonEncode(result['objectData']),
      );
      await storage.write(
        key: 'profileFirstName',
        value: user['firstName'],
      );
      await storage.write(
        key: 'profileLastName',
        value: user['lastName'],
      );
      await storage.write(
        key: 'profileImageUrl',
        value: user['imageUrl'],
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => UserInformationPage(),
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
                'อัพเดตข้อมูลเรียบร้อยแล้ว',
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
                      color: Color(0xFF9A1120),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomeMartPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    // goBack();
                    // Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: new Text(
                'อัพเดตข้อมูลไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: new Text(
                result['message'],
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF9A1120),
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
        },
      );
    }
  }

  readStorage() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value);

    if (user['code'] != '') {
      setState(() {
        _imageUrl = user['imageUrl'] ?? '';
        txtFirstName.text = user['firstName'] ?? '';
        txtLastName.text = user['lastName'] ?? '';
        txtEmail.text = user['email'] ?? '';
        txtPhone.text = user['phone'] ?? '';
        _selectedPrefixName = user['prefixName'];
        txtPrefixName.text = user['prefixName'] ?? '';
        _code = user['code'];
        _selectedProvince = user['provinceCode'] ?? '';
        _selectedDistrict = user['amphoeCode'] ?? '';
        _selectedSubDistrict = user['tambonCode'] ?? '';
        _selectedPostalCode = user['postnoCode'] ?? '';
      });

      if (user['birthDay'] != '') {
        var date = user['birthDay'];
        var year = date.substring(0, 4);
        var month = date.substring(4, 6);
        var day = date.substring(6, 8);
        DateTime todayDate = DateTime.parse(year + '-' + month + '-' + day);

        setState(() {
          _selectedYear = todayDate.year;
          _selectedMonth = todayDate.month;
          _selectedDay = todayDate.day;
          txtDate.text = DateFormat("dd-MM-yyyy").format(todayDate);
        });
      }

      if (_selectedProvince != '') {
        getProvince();
        getDistrict();
        getSubDistrict();
        getPostalCode();
        // setState(() {
        //   futureModel = getUser();
        // });
      } else {
        getProvince();
        // setState(() {
        //   futureModel = getUser();
        // });
      }
    }
  }

  dialogOpenPickerDate() {
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
        maxTime: DateTime(year, month, day), onConfirm: (date) {
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
        locale: LocaleType.th);
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: [
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
            labelTextFormField('วันเดือนปีเกิด'),
            GestureDetector(
              onTap: () => dialogOpenPickerDate(),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: txtDate,
                  style: TextStyle(
                    color: Color(0xFF000070),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                    fontSize: 15.0,
                  ),
                  decoration: InputDecoration(
                    // filled: true,
                    // fillColor: Color(0xFFC5DAFC),
                    contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    hintText: "วันเดือนปีเกิด",
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(10.0),
                    //   borderSide: BorderSide.none,
                    // ),
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
            labelTextFormField('อีเมล'),
            textFormFieldNoValidator(
              txtEmail,
              'อีเมล',
              true,
              true,
            ),
            labelTextFormField('ที่อยู่'),
            textFormField(
              txtAddress,
              null,
              'ที่อยู่',
              'ที่อยู่',
              true,
              false,
              false,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Container(
                // width: MediaQuery.of(context).size.width * 0.7,
                // margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFFFF7514),
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 40,
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        form.save();
                        submitUpdateUser();
                      }
                    },
                    child: new Text(
                      'บันทึกข้อมูล',
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
      ),
    );
  }

  rowContentButton(String urlImage, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
            child: new Padding(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(
                urlImage,
                height: 5.0,
                width: 5.0,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color(0xFF0B5C9E),
            ),
            width: 30.0,
            height: 30.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.63,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              title,
              style: new TextStyle(
                fontSize: 12.0,
                color: Color(0xFF9A1120),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Image.asset(
              "assets/icons/Group6232.png",
              height: 20.0,
              width: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  _imgFromCamera() async {
    XFile image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    setState(() {
      _image = image;
    });
    _upload();
  }

  _imgFromGallery() async {
    XFile image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    setState(() {
      _image = image;
    });
    _upload();
  }

  _imgFromNow() async {
    setState(() {
      _imageUrl = _imageUrlSocial;
    });
  }

  void _upload() async {
    if (_image == null) return;

    uploadImage(_image).then((res) {
      setState(() {
        _imageUrl = res;
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _showPickerImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      'อัลบั้มรูปภาพ',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    'กล้องถ่ายรูป',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
                if (_categorySocial != '')
                  new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      ' ใช้รูปโปรไฟล์จาก ' + _categorySocial,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _imgFromNow();
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => UserInformationPage(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
  }
}
