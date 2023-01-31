import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

headerCalendar(
  BuildContext context,
  Function functionGoBack,
  bool showCalendar, {
  String title = '',
  Function rightButton,
}) {
  return AppBar(
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFFFF7900),
            Color(0xFFFF7900),
          ],
        ),
      ),
    ),
    backgroundColor: Color(0xFF000070),
    elevation: 0.0,
    titleSpacing: 5,
    automaticallyImplyLeading: false,
    title: Text(
      title != null ? title : '',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
      ),
    ),
    leading: InkWell(
      onTap: () => functionGoBack(),
      child: Container(
        child: Image.asset(
          "assets/images/arrow_left.png",
          color: Colors.white,
          width: 40,
          height: 40,
        ),
      ),
    ),
    actions: <Widget>[
      Container(
        child: Container(
          child: Container(
            width: 42.0,
            height: 42.0,
            margin: EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => rightButton(),
              // child: Image.asset('assets/images/task_list.png'),
              child: showCalendar
                  ? Image.asset('assets/images/sort.png')
                  : Image.asset('assets/images/task_list.png'),
            ),
          ),
        ),
      )
    ],
  );
}
