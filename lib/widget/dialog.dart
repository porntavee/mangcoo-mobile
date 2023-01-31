import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';

dialog(BuildContext context,
    {String title,
    String description,
    bool isYesNo = false,
    String btnOk = 'ตกลง',
    String btnCancel = 'ยกเลิก',
    Function callBack}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: new Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor,
                  ],
                ),
              ),
              child: CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text(
                  btnOk,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  if (isYesNo) {
                    Navigator.pop(context, false);
                    callBack();
                  } else {
                    Navigator.pop(context, false);
                  }
                },
              ),
            ),
            if (isYesNo)
              Container(
                color: Color(0xFF707070),
                child: CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    btnCancel,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
          ],
        );
      });
}

dialogVersion(BuildContext context,
    {String title,
    String description,
    bool isYesNo = false,
    Function callBack}) {
  return CupertinoAlertDialog(
    title: new Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontFamily: 'Kanit',
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
    ),
    content: Column(
      children: [
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'เวอร์ชั่นปัจจุบัน ' + versionName,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
    actions: [
      Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        child: CupertinoDialogAction(
          isDefaultAction: true,
          child: new Text(
            "อัพเดท",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () {
            if (isYesNo) {
              callBack(true);
              // Navigator.pop(context, false);
            } else {
              callBack(true);
              // Navigator.pop(context, false);
            }
          },
        ),
      ),
      if (isYesNo)
        Container(
          color: Color(0xFF707070),
          child: CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "ภายหลัง",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              callBack(false);
              Navigator.pop(context, false);
            },
          ),
        ),
    ],
  );
}

dialogBtn(BuildContext context,
    {String title,
    String description,
    bool isYesNo = false,
    String btnOk = 'ตกลง',
    String btnCancel = 'ยกเลิก',
    Function callBack}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: new Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor,
                  ],
                ),
              ),
              child: CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text(
                  btnOk,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                  callBack(true);
                },
              ),
            ),
            if (isYesNo)
              Container(
                color: Color(0xFFE84C10),
                child: CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    btnCancel,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                    callBack(false);
                  },
                ),
              ),
          ],
        );
      });
}
