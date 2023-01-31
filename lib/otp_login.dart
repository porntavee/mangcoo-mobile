import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/dialog.dart';
import 'package:wereward/widget/ink_well_unfocus.dart';

class OTPLoginPage extends StatefulWidget {
  const OTPLoginPage({Key key, @required this.userData}) : super(key: key);

  final dynamic userData;

  @override
  _OTPLoginPageState createState() => _OTPLoginPageState();
}

class _OTPLoginPageState extends State<OTPLoginPage> {
  final storage = new FlutterSecureStorage();
  PageController pageController;
  int currentPageValue = 0;
  String legion = '';
  bool loadingPage = false;
  TextEditingController oneController;
  TextEditingController twoController;
  TextEditingController threeController;
  TextEditingController fourController;
  TextEditingController fiveController;
  TextEditingController sixController;
  TextEditingController legionController;
  TextEditingController phoneController;
  String otpNumber = '';
  List<TextEditingController> listTextEditingController;
  dynamic _otp;

  @override
  void initState() {
    oneController = new TextEditingController();
    twoController = new TextEditingController();
    threeController = new TextEditingController();
    fourController = new TextEditingController();
    fiveController = new TextEditingController();
    sixController = new TextEditingController();
    legionController = new TextEditingController();
    phoneController = new TextEditingController();

    listTextEditingController = [
      oneController,
      twoController,
      threeController,
      fourController,
      fiveController,
      sixController,
    ];

    pageController = new PageController();
    setData();
    super.initState();
  }

  setData() {
    setState(() {
      phoneController.text = widget.userData['phone'] ?? '';
    });
  }

  setTime() async {
    await Future.delayed(Duration(milliseconds: 2000)).then(
      (value) => setState(() {
        oneController.text = '1';
        twoController.text = '2';
        threeController.text = '3';
        fourController.text = '4';
      }),
    );
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    oneController.dispose();
    twoController.dispose();
    threeController.dispose();
    fourController.dispose();
    legionController.dispose();
    phoneController.dispose();
    super.dispose();
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
        resizeToAvoidBottomInset: false,
        body: InkWellUnfocus(
          child: _buildBody(),
        ),
      ),
    );
  }

  _buildBody() {
    return Stack(
      children: [
        PageView(
          controller: pageController,
          onPageChanged: (int page) {
            setState(() {
              currentPageValue = page;
            });
          },
          physics: new NeverScrollableScrollPhysics(),
          children: [
            _buildPageSendMessage(),
            _buildPageConfirmOTP(),
            Container(),
          ],
        ),
        if (loadingPage)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.6),
              child: CupertinoActivityIndicator(radius: 30),
            ),
          )
      ],
    );
  }

  Stack _buildPageSendMessage() {
    return Stack(
      children: [
        Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.phonelink_ring_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                decoration: new BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    TextField(
                      enabled: false,
                      controller: legionController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                        hintText: 'Thailand (+66)',
                        hintStyle: TextStyle(
                          // color: Colors.white70,
                          fontFamily: 'Kanit',
                          fontSize: 15,
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
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (value) {
                        if (value.length == 10)
                          FocusScope.of(context).unfocus();
                      },
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'เบอร์โทรศัพท์ของคุณ',
                        hintStyle: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                        suffixIcon: IconButton(
                          onPressed: phoneController.clear,
                          icon: Icon(Icons.clear),
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
                    ),
                    SizedBox(height: 30),
                    Text(
                      'We will send you a one time SMS message.\n Carrier rates many apply.',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (phoneController.text.length == 10) {
                            Random rn = new Random();
                            otpNumber = '';
                            for (var i = 0; i < 4; i++) {
                              rn.nextInt(9);
                              setState(() {
                                otpNumber += rn.nextInt(9).toString();
                              });
                            }
                            setState(() {
                              currentPageValue = 1;
                              pageController.jumpToPage(1);
                            });

                            sendOTP();

                            // return Flushbar(
                            //   onTap: (value) => {
                            //     oneController.text = otpNumber.substring(0, 1),
                            //     twoController.text = otpNumber.substring(1, 2),
                            //     threeController.text =
                            //         otpNumber.substring(2, 3),
                            //     fourController.text = otpNumber.substring(3, 4),
                            //   },
                            //   flushbarPosition: FlushbarPosition.TOP,
                            //   margin: EdgeInsets.all(8),
                            //   borderRadius: 8,
                            //   message: "OTP : " +
                            //       otpNumber +
                            //       ' is your verification code',
                            //   icon: Icon(
                            //     Icons.info_outline,
                            //     size: 28.0,
                            //     color: Colors.blue[300],
                            //   ),
                            //   duration: Duration(seconds: 3),
                            // ).show(context);

                            // setTime();
                          } else
                            toastFail(context,
                                text: phoneController.text.length == 0
                                    ? 'กรุณากรอกหมายเลขโทรศัพท์'
                                    : 'หมายเลขโทรศัพท์ไม่ถูกต้อง');
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 13,
          left: 13,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Stack _buildPageConfirmOTP() {
    return Stack(
      children: [
        Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      MediaQuery.of(context).size.height * 0.1,
                ),
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    colors: [
                      Theme.of(context).accentColor,
                      Theme.of(context).primaryColor,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Verification Code',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please type the verification code sent \n to +66 ' +
                          phoneController.text,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: listTextEditingController
                          .map<Widget>(
                            (e) => _buidInputNum(
                              controller: e,
                              onChange: (value) => {
                                if (value != '')
                                  {
                                    if (e == sixController)
                                      FocusScope.of(context).unfocus()
                                    else
                                      FocusScope.of(context).nextFocus()
                                  }
                                else
                                  FocusScope.of(context).previousFocus()
                              },
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 70),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async => confirm(),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 13,
          left: 13,
          child: IconButton(
            onPressed: () => {
              FocusScope.of(context).unfocus(),
              setState(() {
                oneController = new TextEditingController();
                twoController = new TextEditingController();
                threeController = new TextEditingController();
                fourController = new TextEditingController();

                currentPageValue = 0;
                pageController.jumpToPage(0);
              }),
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  _buidInputNum({TextEditingController controller, Function onChange}) {
    var color = Colors.white.withOpacity(0.8);
    return Container(
      width: 40,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: TextField(
        // autofocus: controller == oneController ? true : false,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          contentPadding: EdgeInsets.only(left: 11.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
        ),
        style: TextStyle(fontSize: 30.0, color: Colors.white),
        onChanged: (value) => onChange(value),
      ),
    );
  }

  sendOTP() async {
    _otp = await postOTPSend('otp-send', {
      "project_key": "XcvVbGHhAi",
      "phone": phoneController.text.replaceAll('-', '').trim(),
      "ref_code": "xxx123"
    });
  }

  validateOTP() async {
    var inputOTP = oneController.text.toString() +
        twoController.text.toString() +
        threeController.text.toString() +
        fourController.text.toString() +
        fiveController.text.toString() +
        sixController.text.toString();

    var validate = await postOTPSend('otp-validate', {
      "token": _otp['token'],
      "otp_code": inputOTP,
      "ref_code": _otp['ref_code']
    });
    if (validate['status']) {
      return false;
    } else {
      return true;
    }
  }

  confirm() async {
    {
      var profileCode = await storage.read(key: 'profileCode10');
      var valid = await validateOTP();
      if (valid) {
        return toastFail(context, text: 'รหัส OTP ไม่ถูกต้อง');
      }

      setState(() {
        loadingPage = true;
      });

      Dio dio = new Dio();
      var response = await dio.post(
        '${server}m/v2/register/verifyphone/update',
        data: {
          'code': profileCode,
          'phone': phoneController.text,
        },
      );

      if (response != null) {
        storage.write(
          key: 'profilePhone',
          value: phoneController.text,
        );
        setState(() {
          loadingPage = false;
        });
        await Future.delayed(Duration(milliseconds: 500)).then(
          (value) => setState(() {
            loadingPage = false;
          }),
        );
        Navigator.pop(context, true);
      } else {
        await Future.delayed(Duration(milliseconds: 100)).then(
          (value) => setState(() {
            loadingPage = false;
          }),
        );
      }
    }
  }
}
