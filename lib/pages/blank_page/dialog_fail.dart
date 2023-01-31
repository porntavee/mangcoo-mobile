import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wereward/splash.dart';

dialogFail(BuildContext context,
    {bool reloadApp = false,
    String text = 'การเชื่อมต่อมีปัญหากรุณาลองใหม่อีกครั้ง'}) {
  return WillPopScope(
    onWillPop: () {
      return Future.value(reloadApp);
    },
    child: Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: CupertinoAlertDialog(
        title: new Text(
          text,
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
              reloadApp
                  ? Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => SplashPage(),
                      ),
                      (Route<dynamic> route) => false,
                    )
                  : Navigator.pop(context, false);
            },
          ),
        ],
      ),
    ),
  );
}
