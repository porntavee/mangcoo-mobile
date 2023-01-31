import 'dart:convert';
import 'package:wereward/widget/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/login.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/text_form_field.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final storage = new FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();

  final txtPasswordOld = TextEditingController();
  final txtPasswordNew = TextEditingController();
  final txtConPasswordNew = TextEditingController();
  String _imageUrl;
  bool showTxtPasswordOld = true;
  bool showTxtPasswordNew = true;
  bool showTxtConPasswordNew = true;

  DateTime selectedDate = DateTime.now();
  TextEditingController dateCtl = TextEditingController();

  Future<dynamic> futureModel;

  ScrollController scrollController = new ScrollController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtPasswordOld.dispose();
    txtPasswordNew.dispose();
    txtConPasswordNew.dispose();
    super.dispose();
  }

  @override
  void initState() {
    readStorage();
    super.initState();
  }

  void logout() async {
    await storage.delete(key: 'dataUserLoginDDPM');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Future<dynamic> submitChangePassword() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value);
    user['password'] = txtPasswordOld.text;
    user['newPassword'] = txtPasswordNew.text;

    final result = await postObjectData('m/Register/change', user);
    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataUserLoginDDPM',
        value: jsonEncode(result['objectData']),
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
        builder: (BuildContext context) => new CupertinoAlertDialog(
          title: new Text(
            'เปลี่ยนรหัสผ่านเรียบร้อยแล้ว',
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
                "ยกเลิก",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  color: Color(0xFF000070),
                  fontWeight: FontWeight.normal,
                ),
              ),
              onPressed: () {
                goBack();
              },
            ),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
          title: new Text(
            'เปลี่ยนรหัสผ่านไม่สำเร็จ',
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
                "ยกเลิก",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  color: Color(0xFF000070),
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
    }
  }

  readStorage() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value);

    if (user['code'] != '') {
      setState(() {
        _imageUrl = user['imageUrl'] ?? '';
      });
    }
  }

  card() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(15), child: contentCard()),
    );
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          labelTextFormFieldPasswordOldNew('รหัสผ่านปัจจุบัน', false),
          TextFormField(
            obscureText: showTxtPasswordOld,
            style: TextStyle(
              color: Color(0xFF000070),
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              fontSize: 15.0,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  showTxtPasswordOld ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    showTxtPasswordOld = !showTxtPasswordOld;
                  });
                },
              ),
              filled: true,
              fillColor: Color(0xFFC5DAFC),
              contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              hintText: 'รหัสผ่านปัจจุบัน',
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
            validator: (model) {
              if (model.isEmpty) {
                return 'กรุณากรอกรหัสผ่านปัจจุบัน.';
              }
            },
            controller: txtPasswordOld,
            enabled: true,
          ),
          labelTextFormFieldPasswordOldNew('รหัสผ่านใหม่', true),
          TextFormField(
            obscureText: showTxtPasswordNew,
            style: TextStyle(
              color: Color(0xFF000070),
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              fontSize: 15.0,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  showTxtPasswordNew ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    showTxtPasswordNew = !showTxtPasswordNew;
                  });
                },
              ),
              filled: true,
              fillColor: Color(0xFFC5DAFC),
              contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              hintText: 'รหัสผ่านใหม่',
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
            validator: (model) {
              if (model.isEmpty) {
                return 'กรุณากรอกรหัสผ่านใหม่.';
              }

              Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,}$';
              RegExp regex = new RegExp(pattern);
              if (!regex.hasMatch(model)) {
                return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
              }
            },
            controller: txtPasswordNew,
            enabled: true,
          ),
          labelTextFormFieldPasswordOldNew('ยืนยันรหัสผ่านใหม่', false),
          TextFormField(
            obscureText: showTxtConPasswordNew,
            style: TextStyle(
              color: Color(0xFF000070),
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              fontSize: 15.0,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  showTxtConPasswordNew
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    showTxtConPasswordNew = !showTxtConPasswordNew;
                  });
                },
              ),
              filled: true,
              fillColor: Color(0xFFC5DAFC),
              contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              hintText: 'ยืนยันรหัสผ่านใหม่',
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
            validator: (model) {
              if (model.isEmpty) {
                return 'กรุณากรอกยืนยันรหัสผ่านใหม่.';
              }

              if (model != txtPasswordNew.text && txtPasswordNew != null) {
                return 'กรุณากรอกรหัสผ่านให้ตรงกัน.';
              }

              Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,}$';
              RegExp regex = new RegExp(pattern);
              if (!regex.hasMatch(model)) {
                return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
              }
            },
            controller: txtConPasswordNew,
            enabled: true,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              margin: EdgeInsets.symmetric(vertical: 10.0),
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
                      submitChangePassword();
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
                color: Color(0xFFFF7514),
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
        appBar: header(
          context,
          title: 'เปลี่ยนรหัสผ่าน',
          isShowLogo: false,
          isCenter: true,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            // padding: const EdgeInsets.all(10.0),
            children: <Widget>[
              new Column(
                // alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      // vertical: 10.0,
                    ),
                    child: contentCard(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
