import 'package:flutter/material.dart';

buttonFull(
    {BuildContext context,
    double width = double.infinity,
    Color backgroundColor = Colors.white,
    String title = '',
    double fontSize = 18.0,
    double elevation = 5.0,
    FontWeight fontWeight = FontWeight.normal,
    Color fontColor = Colors.black,
    EdgeInsets margin,
    EdgeInsets padding,
    Function callback}) {
  return Center(
    child: Container(
      width: width,
      margin: margin,
      child: Material(
        elevation: elevation,
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
              fontWeight: fontWeight,
              fontFamily: 'Kanit',
            ),
          ),
        ),
      ),
    ),
  );
}
