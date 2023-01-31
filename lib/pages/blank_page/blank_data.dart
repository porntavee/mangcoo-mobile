import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wereward/pages/blank_page/blank_loading.dart';

blankListData(BuildContext context, {double height = 100}) {
  return Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    padding: EdgeInsets.only(left: 10.0, right: 10.0),
    child: ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 5.0),
          child: BlankLoading(height: height),
        );
      },
    ),
  );
}

blankGridData(BuildContext context, {double height = 100}) {
  return Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    padding: EdgeInsets.only(left: 10.0, right: 10.0),
    child: GridView.count(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      children: new List<Widget>.generate(
        10,
        (index) {
          return Container(
            margin: index % 2 == 0
                ? EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0)
                : EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
            child: BlankLoading(height: height),
          );
        },
      ),
    ),
  );
}
