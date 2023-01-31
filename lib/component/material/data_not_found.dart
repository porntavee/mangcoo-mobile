import 'package:flutter/material.dart';

class DataNotFound extends StatefulWidget {
  @override
  _DataNotFoundState createState() => _DataNotFoundState();
}

class _DataNotFoundState extends State<DataNotFound> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      alignment: Alignment.center,
      child: Text(
        'ไม่พบข้อมูล',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
        ),
      ),
    );
  }
}
