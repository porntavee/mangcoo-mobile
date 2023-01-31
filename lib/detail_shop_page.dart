import 'dart:async';
import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';

class DetailShopPage extends StatefulWidget {
  DetailShopPage({Key key, this.future}) : super(key: key);

  final Future<dynamic> future;

  @override
  _DetailShopPageState createState() => _DetailShopPageState();
}

class _DetailShopPageState extends State<DetailShopPage> {
  Future<dynamic> _futureModel;
  List<dynamic> categoryList;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

// Be sure to cancel subscription after you are done
  @override
  dispose() {
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
        appBar: header2(
          context,
          title: 'ตั้งค่าการแจ้งเตือน',
        ),
        backgroundColor: Colors.white,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }

  _callRead() async {
    _futureModel = postDio('${promotionApi}read', {});
  }
}
