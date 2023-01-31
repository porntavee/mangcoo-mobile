import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';

header(
  BuildContext context, {
  String title = appName,
  bool isShowLogo = true,
  bool isCenter = false,
  bool isShowButtonCalendar = false,
  bool isButtonCalendar = false,
  bool isShowButtonPoi = false,
  bool isButtonPoi = false,
  bool isShowButtonFilter = false,
  bool isButtonFilter = false,
  Function callBackClickButtonCalendar,
}) {
  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    centerTitle: isCenter,
    title: isCenter
        ? Text(
            title,
            style: TextStyle(
              fontFamily: 'Kanit',
            ),
          )
        : Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isShowLogo)
                Image.asset(
                  'assets/images/logo.png',
                  height: 50,
                ),
              // Image.asset(
              //   'assets/logo/logo.png',
              //   height: 50,
              // ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                  ),
                ),
              )
            ],
          ),
    actions: [
      if (isShowButtonCalendar)
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10.0),
          margin: EdgeInsets.only(right: 10, top: 12, bottom: 12),
          width: 70,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: InkWell(
            onTap: () {
              callBackClickButtonCalendar();
            },
            child: isButtonCalendar
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list,
                        color: Color(0xFF1B6CA8),
                        size: 15,
                      ),
                      Text(
                        'รายการ',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF1B6CA8),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/icon_header_calendar_1.png'),
                      Text(
                        'ปฏิทิน',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF1B6CA8),
                        ),
                      ),
                      // widgetText(
                      //     title: 'ปฏิทิน', fontSize: 9, color: 0xFF1B6CA8),
                    ],
                  ),
          ),
        ),
      if (isShowButtonPoi)
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: 10.0),
          margin: EdgeInsets.only(right: 10, top: 12, bottom: 12),
          width: 70,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: InkWell(
            onTap: () {
              callBackClickButtonCalendar();
            },
            child: isButtonPoi
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list,
                        color: Color(0xFF1B6CA8),
                        size: 15,
                      ),
                      Text(
                        'รายการ',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF1B6CA8),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF1B6CA8),
                        size: 20,
                      ),
                      // Image.asset('assets/icon_header_calendar_1.png'),
                      Text(
                        'แผนที่',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF1B6CA8),
                        ),
                      ),
                      // widgetText(
                      //     title: 'ปฏิทิน', fontSize: 9, color: 0xFF1B6CA8),
                    ],
                  ),
          ),
        ),
      if (isShowButtonFilter)
        GestureDetector(
          onTap: () {
            callBackClickButtonCalendar();
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(right: 5, top: 5, bottom: 12),
            width: 70,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.list,
                  color: Color(0xFFFFFFFF),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

header2(BuildContext context,
    {String title = '', bool customBack = false, Function func}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    automaticallyImplyLeading: false,
    elevation: 0,
    // toolbarHeight: MediaQuery.of(context).padding.top,
    flexibleSpace: Container(
      height: 57 + MediaQuery.of(context).padding.top,
      alignment: Alignment.centerLeft,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          IconButton(
            iconSize: 27,
            splashRadius: 20,
            alignment: Alignment.center,
            onPressed: () {
              if (customBack) {
                func();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
