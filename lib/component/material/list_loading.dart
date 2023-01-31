import 'package:wereward/pages/blank_page/blank_loading.dart';
import 'package:flutter/material.dart';

listLoading({int count = 10, double height = 150}) {
  return ListView.builder(
    shrinkWrap: true,
    physics: ClampingScrollPhysics(),
    itemCount: count,
    itemBuilder: (context, index) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        height: height,
        child: BlankLoading(),
      );
    },
  );
}
