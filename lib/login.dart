import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:wereward/pages/auth/forgot_password.dart';
import 'package:wereward/register.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/apple_firebase.dart';
import 'package:wereward/shared/facebook_firebase.dart';
import 'package:wereward/shared/google_firebase.dart';
import 'package:wereward/widget/text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_mart.dart';
import 'shared/line.dart';

DateTime now = new DateTime.now();
void main() {
  // Intl.defaultLocale = 'th';
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = new FlutterSecureStorage();

  String _username;
  String _password;
  String _facebookID;
  String _appleID;
  String _googleID;
  String _lineID;
  String _email;
  String _imageUrl;
  String _category;
  String _prefixName;
  String _firstName;
  String _lastName;

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  bool showVisibility = false;
  bool statusVisibility = true;

  @override
  void initState() {
    setState(() {
      _username = "";
      _password = "";
      _facebookID = "";
      _appleID = "";
      _googleID = "";
      _lineID = "";
      _email = "";
      _imageUrl = "";
      _category = "";
      _prefixName = "";
      _firstName = "";
      _lastName = "";
    });
    super.initState();
  }

  @override
  void dispose() {
    txtUsername.dispose();
    txtPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBackground();
  }

  _buildBackground() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      child: _buildScaffold(),
    );
  }

  _buildWillPopScope() {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: _buildScaffold(),
    );
  }

  _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          child: ListView(
            padding: EdgeInsets.only(top: 70, left: 20, right: 20),
            children: [
              Center(
                child: Image.asset(
                  "assets/icon.png",
                  fit: BoxFit.contain,
                  height: 80.0,
                ),
              ),
              Card(
                margin: EdgeInsets.only(top: 20),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _widgetText(title: 'เข้าสู่ระบบ'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '',
                            style: TextStyle(
                              fontSize: 14.00,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          Text(
                            ' เข้าสู่ระบบโดย ',
                            style: TextStyle(
                              fontSize: 14.00,
                              fontFamily: 'Kanit',
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            '',
                            style: TextStyle(
                              fontSize: 14.00,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (Platform.isIOS)
                            new Container(
                              alignment: new FractionalOffset(0.5, 0.5),
                              height: 50.0,
                              width: 50.0,
                              child: new IconButton(
                                onPressed: () async {
                                  var obj = await signInWithApple();

                                  // print('----- email ----- ${obj.credential}');
                                  // print(obj.credential.identityToken[4]);
                                  // print(obj.credential.identityToken[8]);

                                  var model = {
                                    "username": obj.user.email != null
                                        ? obj.user.email
                                        : obj.user.uid,
                                    "email": obj.user.email != null
                                        ? obj.user.email
                                        : '',
                                    "imageUrl": '',
                                    "firstName": obj.user.email,
                                    "lastName": '',
                                    "appleID": obj.user.uid
                                  };

                                  // print(model.toString());

                                  Dio dio = new Dio();
                                  var response = await dio.post(
                                    '${server}m/v2/register/apple/login',
                                    data: model,
                                  );

                                  // print(
                                  //     '----- code ----- ${response.data['objectData']['code']}');

                                  createStorageApp(
                                    model: response.data['objectData'],
                                    category: 'apple',
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeMartPage(),
                                    ),
                                  );

                                  // if (response.data['objectData']['phone'] !=
                                  //         '' &&
                                  //     response.data['objectData']['phone'] !=
                                  //         null) {
                                  //   if (obj != null) {
                                  //     Navigator.pushReplacement(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => HomeMartPage(),
                                  //       ),
                                  //     );
                                  //   }
                                  // } else {
                                  //   Navigator.push(
                                  //     context,
                                  //     fadeNav(OTPLoginPage(userData: model)),
                                  //   ).then(
                                  //     (value) => {
                                  //       if (value)
                                  //         {
                                  //           Navigator.pushReplacement(
                                  //             context,
                                  //             MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   HomeMartPage(),
                                  //             ),
                                  //           )
                                  //         }
                                  //       else
                                  //         logout(context)
                                  //     },
                                  //   );
                                  // }
                                },
                                icon: new Image.asset(
                                  "assets/images/apple_circle.png",
                                ),
                                padding: new EdgeInsets.all(5.0),
                              ),
                            ),
                          new Container(
                            alignment: new FractionalOffset(0.5, 0.5),
                            height: 50.0,
                            width: 50.0,
                            child: new IconButton(
                              onPressed: () async {
                                var obj = await signInWithFacebook();
                                // print('-----${obj.toString()}-----');

                                var model = {
                                  "username": obj.user.email,
                                  "email": obj.user.email,
                                  "imageUrl": obj.user.photoURL != null
                                      ? obj.user.photoURL
                                      : '',
                                  "firstName": obj.user.displayName,
                                  "lastName": '',
                                  "facebookID": obj.user.uid
                                };

                                Dio dio = new Dio();
                                var response = await dio.post(
                                  '${server}m/v2/register/facebook/login',
                                  data: model,
                                );

                                // print(response.data['objectData']['code']);

                                await storage.write(
                                  key: 'categorySocial',
                                  value: 'Facebook',
                                );

                                await storage.write(
                                  key: 'imageUrlSocial',
                                  value: model['imageUrl'],
                                );

                                createStorageApp(
                                  model: response.data['objectData'],
                                  category: 'facebook',
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeMartPage(),
                                  ),
                                );

                                // if (response.data['objectData']['phone'] !=
                                //         '' &&
                                //     response.data['objectData']['phone'] !=
                                //         null) {
                                //   if (obj != null) {
                                //     Navigator.pushReplacement(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => HomeMartPage(),
                                //       ),
                                //     );
                                //   }
                                // } else {
                                //   Navigator.push(
                                //     context,
                                //     fadeNav(OTPLoginPage(userData: model)),
                                //   ).then(
                                //     (value) => {
                                //       if (value)
                                //         {
                                //           Navigator.pushReplacement(
                                //             context,
                                //             MaterialPageRoute(
                                //               builder: (context) =>
                                //                   HomeMartPage(),
                                //             ),
                                //           )
                                //         }
                                //       else
                                //         logout(context)
                                //     },
                                //   );
                                // }
                              },
                              icon: new Image.asset(
                                "assets/images/facebook_circle.png",
                              ),
                              padding: new EdgeInsets.all(5.0),
                            ),
                          ),
                          new Container(
                            alignment: new FractionalOffset(0.5, 0.5),
                            height: 50.0,
                            width: 50.0,
                            child: new IconButton(
                              onPressed: () async {
                                var obj = await signInWithGoogle();
                                // print('----- Login Google ----- ' + obj.toString());
                                if (obj != null) {
                                  var model = {
                                    "username": obj.user.email,
                                    "email": obj.user.email,
                                    "imageUrl": obj.user.photoURL != null
                                        ? obj.user.photoURL
                                        : '',
                                    "firstName": obj.user.displayName,
                                    "lastName": '',
                                    "googleID": obj.user.uid
                                  };

                                  Dio dio = new Dio();
                                  var response = await dio.post(
                                    '${server}m/v2/register/google/login',
                                    data: model,
                                  );

                                  await storage.write(
                                    key: 'categorySocial',
                                    value: 'Google',
                                  );

                                  await storage.write(
                                    key: 'imageUrlSocial',
                                    value: obj.user.photoURL != null
                                        ? obj.user.photoURL
                                        : '',
                                  );

                                  createStorageApp(
                                    model: response.data['objectData'],
                                    category: 'google',
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeMartPage(),
                                    ),
                                  );

                                  // if (response.data['objectData']['phone'] !=
                                  //         '' &&
                                  //     response.data['objectData']['phone'] !=
                                  //         null) {
                                  //   if (obj != null) {
                                  //     Navigator.pushReplacement(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => HomeMartPage(),
                                  //       ),
                                  //     );
                                  //   }
                                  // } else {
                                  //   Navigator.push(
                                  //     context,
                                  //     fadeNav(OTPLoginPage(userData: model)),
                                  //   ).then(
                                  //     (value) => {
                                  //       if (value)
                                  //         {
                                  //           Navigator.pushReplacement(
                                  //             context,
                                  //             MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   HomeMartPage(),
                                  //             ),
                                  //           )
                                  //         }
                                  //       else
                                  //         logout(context)
                                  //     },
                                  //   );
                                  // }
                                }
                              },
                              icon: new Image.asset(
                                "assets/images/google_circle.png",
                              ),
                              padding: new EdgeInsets.all(5.0),
                            ),
                          ),
                          new Container(
                            alignment: new FractionalOffset(0.5, 0.5),
                            height: 50.0,
                            width: 50.0,
                            child: new IconButton(
                              onPressed: () async {
                                var obj = await loginLine();
                                final idToken = obj.accessToken.idToken;
                                final userEmail = (idToken != null)
                                    ? idToken['email'] != null
                                        ? idToken['email']
                                        : ''
                                    : '';

                                if (obj != null) {
                                  var model = {
                                    "username":
                                        (userEmail != '' && userEmail != null)
                                            ? userEmail
                                            : obj.userProfile.userId,
                                    "email": userEmail,
                                    "imageUrl": (obj.userProfile.pictureUrl !=
                                                '' &&
                                            obj.userProfile.pictureUrl != null)
                                        ? obj.userProfile.pictureUrl
                                        : '',
                                    "firstName": obj.userProfile.displayName,
                                    "lastName": '',
                                    "lineID": obj.userProfile.userId
                                  };

                                  Dio dio = new Dio();
                                  var response = await dio.post(
                                    '${server}m/v2/register/line/login',
                                    data: model,
                                  );

                                  await storage.write(
                                    key: 'categorySocial',
                                    value: 'Line',
                                  );

                                  await storage.write(
                                    key: 'imageUrlSocial',
                                    value: (obj.userProfile.pictureUrl != '' &&
                                            obj.userProfile.pictureUrl != null)
                                        ? obj.userProfile.pictureUrl
                                        : '',
                                  );

                                  createStorageApp(
                                    model: response.data['objectData'],
                                    category: 'line',
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeMartPage(),
                                    ),
                                  );

                                  // if (response.data['objectData']['phone'] !=
                                  //         '' &&
                                  //     response.data['objectData']['phone'] !=
                                  //         null) {
                                  //   if (obj != null) {
                                  //     Navigator.pushReplacement(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => HomeMartPage(),
                                  //       ),
                                  //     );
                                  //   }
                                  // } else {
                                  //   Navigator.push(
                                  //     context,
                                  //     fadeNav(OTPLoginPage(userData: model)),
                                  //   ).then(
                                  //     (value) => {
                                  //       if (value)
                                  //         {
                                  //           Navigator.pushReplacement(
                                  //             context,
                                  //             MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   HomeMartPage(),
                                  //             ),
                                  //           )
                                  //         }
                                  //       else
                                  //         logout(context)
                                  //     },
                                  //   );
                                  // }
                                }
                              },
                              icon: new Image.asset(
                                "assets/images/line_circle.png",
                              ),
                              padding: new EdgeInsets.all(5.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      textFieldLogin(
                        model: txtUsername,
                        hintText: 'ชื่อผู้ใช้งาน',
                      ),
                      SizedBox(height: 15.0),
                      SizedBox(height: 5.0),
                      textFieldLogin(
                          model: txtPassword,
                          hintText: 'รหัสผ่าน',
                          showVisibility: showVisibility,
                          visibility: statusVisibility,
                          enabled: true,
                          isPassword: true,
                          onChanged: () {
                            if (txtPassword.text.isNotEmpty)
                              setState(() {
                                showVisibility = true;
                              });
                            else
                              setState(() {
                                showVisibility = false;
                              });
                          },
                          callback: () {
                            setState(() {
                              statusVisibility = !statusVisibility;
                            });
                          }),
                      // textField(
                      //   txtPassword,
                      //   null,
                      //   'รหัสผ่าน',
                      //   'รหัสผ่าน',
                      //   true,
                      //   true,
                      // ),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildLoginButton(),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              "ลืมรหัสผ่าน",
                              style: TextStyle(
                                fontSize: 12.00,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                          Text(
                            '|',
                            style: TextStyle(
                              fontSize: 15.00,
                              fontFamily: 'Kanit',
                              color: Colors.blueAccent,
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new RegisterPage(
                                    username: "",
                                    password: "",
                                    facebookID: "",
                                    appleID: "",
                                    googleID: "",
                                    lineID: "",
                                    email: "",
                                    imageUrl: "",
                                    category: "guest",
                                    prefixName: "",
                                    firstName: "",
                                    lastName: "",
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "สมัครสมาชิก",
                              style: TextStyle(
                                fontSize: 12.00,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildLoginButton() {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Theme.of(context).primaryColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        height: 40,
        onPressed: () {
          loginWithGuest();
        },
        child: new Text(
          'เข้าสู่ระบบ',
          style: new TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );
  }

  _buildDialog(String param) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(
          param,
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
      ),
    );
  }

  _widgetText({String title, double fontSize = 18}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: 'Kanit',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  //login username / password
  Future<dynamic> login() async {
    if ((_username == null || _username == '') && _category == 'guest') {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
          title: new Text(
            'กรุณากรอกชื่อผู้ใช้',
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
        ),
      );
    } else if ((_password == null || _password == '') && _category == 'guest') {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
          title: new Text(
            'กรุณากรอกรหัสผ่าน',
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
        ),
      );
    } else {
      // print('----- start login -----');

      // String url = _category == 'guest'
      //     ? 'm/Register/login'
      //     : 'm/Register/${_category}/login';

      // print('----- url ----- $url');

      // final result = await postLoginRegister(url, {
      //   'username': _username.toString(),
      //   'password': _password.toString(),
      //   'category': _category.toString(),
      //   'email': _email.toString(),
      // });

      Dio dio = new Dio();
      var response = await dio.post(
        '${server}m/register/login',
        data: {
          'username': _username.toString(),
          'password': _password.toString()
        },
      );
      // print('----- response ----- ${response.toString()}');

      if (response.data['status'] == 'S') {
        FocusScope.of(context).unfocus();
        new TextEditingController().clear();
        createStorageApp(
          model: response.data['objectData'],
          category: 'guest',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeMartPage(),
          ),
        );
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text(
              'ชื่อผู้ใช้งาน/รหัสผ่าน ไม่ถูกต้อง',
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
                  FocusScope.of(context).unfocus();
                  new TextEditingController().clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }

      // if (result.status == 'S' || result.status == 's') {
      //   createStorageApp(
      //     model: result.objectData.code,
      //     category: 'guest',
      //   );

      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => HomeMartPage(),
      //     ),
      //   );

      //   // await storage.write(
      //   //   key: 'dataUserLoginDDPM',
      //   //   value: jsonEncode(result.objectData),
      //   // );

      //   // Navigator.of(context).pushAndRemoveUntil(
      //   //   MaterialPageRoute(
      //   //     builder: (context) => HomeMartPage(),
      //   //   ),
      //   //   (Route<dynamic> route) => false,
      //   // );
      // }

      // else {
      //   if (_category == 'guest') {
      //     return showDialog(
      //       barrierDismissible: false,
      //       context: context,
      //       builder: (BuildContext context) => new CupertinoAlertDialog(
      //         title: new Text(
      //           result.message,
      //           style: TextStyle(
      //             fontSize: 16,
      //             fontFamily: 'Kanit',
      //             color: Colors.black,
      //             fontWeight: FontWeight.normal,
      //           ),
      //         ),
      //         content: Text(" "),
      //         actions: [
      //           CupertinoDialogAction(
      //             isDefaultAction: true,
      //             child: new Text(
      //               "ตกลง",
      //               style: TextStyle(
      //                 fontSize: 13,
      //                 fontFamily: 'Kanit',
      //                 color: Color(0xFF000070),
      //                 fontWeight: FontWeight.normal,
      //               ),
      //             ),
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //           ),
      //         ],
      //       ),
      //     );
      //   } else {
      //     register();
      //   }
      // }
    }
  }

  Future<dynamic> register() async {
    final result = await postLoginRegister('m/Register/create', {
      'username': _username,
      'password': _password,
      'category': _category,
      'email': _email,
      'facebookID': _facebookID,
      'appleID': _appleID,
      'googleID': _googleID,
      'lineID': _lineID,
      'imageUrl': _imageUrl,
      'prefixName': _prefixName,
      'firstName': _firstName,
      'lastName': _lastName,
      'status': "N",
      'platform': Platform.operatingSystem.toString(),
      'birthDay': "",
      'phone': "",
      'countUnit': "[]"
    });

    if (result.status == 'S') {
      await storage.write(
        key: 'dataUserLoginDDPM',
        value: jsonEncode(result.objectData),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeMartPage(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
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

  //login guest
  void loginWithGuest() async {
    setState(() {
      _category = 'guest';
      _username = txtUsername.text;
      _password = txtPassword.text;
      _facebookID = "";
      _appleID = "";
      _googleID = "";
      _lineID = "";
      _email = "";
      _imageUrl = "";
      _prefixName = "";
      _firstName = "";
      _lastName = "";
    });
    login();
  }

  TextStyle style = TextStyle(
    fontFamily: 'Kanit',
    fontSize: 18.0,
  );
}
