import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/text_form_field.dart';
import '../../login.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final txtEmail = TextEditingController();

  @override
  void dispose() {
    txtEmail.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> submitForgotPassword() async {
    postObjectData('m/Register/forgot/password', {
      'email': txtEmail.text,
    });
    // final result = await postObjectData('m/Register/forgot/password', {
    //   'email': txtEmail.text,
    // });

    setState(() {
      txtEmail.text = '';
    });
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
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
                "ตกลง",
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
        );
      },
    );

    // if (result['status'] == 'S') {
    //   return showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         content: Text(result['message'].toString()),
    //       );
    //     },
    //   );
    // } else {
    //   return showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         content: Text(result['message'].toString()),
    //       );
    //     },
    //   );
    // }
  }

  void goBack() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // image: DecorationImage(
        //   image: AssetImage("assets/images/background_login.png"),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: GestureDetector(
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
          appBar: header(context, goBack, title: 'ลืมรหัสผ่าน'),
          backgroundColor: Colors.transparent,
          body: Container(
            child: Container(
              child: ListView(
                children: <Widget>[
                  new Container(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                  child: Text(
                                    'กรอกอีเมลเพื่อรับรหัสผ่านใหม่ ระบบจะส่งรหัสผ่านใหม่ไปยังอีเมลของคุณ',
                                    style: TextStyle(
                                      fontSize: 18.00,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                labelTextFormField('อีเมล'),
                                textFormField(
                                  txtEmail,
                                  null,
                                  'อีเมล',
                                  'อีเมล',
                                  true,
                                  false,
                                  true,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    margin: EdgeInsets.only(
                                      top: 20.0,
                                      bottom: 10.0,
                                    ),
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Theme.of(context).primaryColor,
                                      child: MaterialButton(
                                        height: 40,
                                        onPressed: () {
                                          final form = _formKey.currentState;
                                          if (form.validate()) {
                                            form.save();
                                            submitForgotPassword();
                                          }
                                        },
                                        child: new Text(
                                          'ยืนยัน',
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
