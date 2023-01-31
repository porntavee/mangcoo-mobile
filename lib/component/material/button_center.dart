import 'package:flutter/material.dart';

buttonCenter(
    {BuildContext context,
    Color backgroundColor = Colors.white,
    String title = '',
    double fontSize = 18.0,
    Color fontColor = Colors.black,
    EdgeInsets margin,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 40.0),
    Function callback}) {
  return Center(
    child: Container(
      margin: margin,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor,
        child: MaterialButton(
          padding: padding,
          height: 40,
          onPressed: () {
            callback();
          },
          child: new Text(
            title,
            style: new TextStyle(
              fontSize: fontSize,
              color: fontColor,
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
            ),
          ),
        ),
      ),
    ),
  );
}
