import 'package:flutter/material.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class ReturnCategoryPage extends StatefulWidget {
  const ReturnCategoryPage({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _ReturnCategoryPageState createState() => _ReturnCategoryPageState();
}

class _ReturnCategoryPageState extends State<ReturnCategoryPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<ReturnCategoryPage> {
  PageController pageController;
  dynamic _model = [
    {'title': 'ฉันไม่ได้รับสินค้าสำหรับคำสั่งซื้อนี้'},
    {'title': 'ได้รับสินค้าที่ไม่สมบุรณ์(ชิ้นส่วนบางชิ้นหายไป)'},
    {'title': 'ได้รับสินค้าที่ไม่ถูกต้องตามที่ตั้ง เช่น สีผิด สินค้าผิด'},
    {'title': 'ได้รับสินค้าสภาพไม่ดี'},
    {'title': 'ได้รับสินค้าที่การทำงานไม่สมบุรณ์'},
    {'title': 'สินค้าผิดลิขสิทธิ์'},
    {'title': 'เปลี่ยนใจ'},
    {'title': 'สินค้ามีความแตกต่างจากรายละเอียดมาก'},
  ];
  int currentPage = 0;

  @override
  void initState() {
    pageController = new PageController();
    _callRead();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        backgroundColor: Colors.white,
        appBar: header2(context, title: ''),
        body: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _titleCategory(1),
                ],
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: new NeverScrollableScrollPhysics(),
                children: [
                  _buildPageLv(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _titleCategory(lv) {
    return GestureDetector(
      onTap: () => setState(() {
        currentPage = lv - 1;
        pageController.animateToPage(lv - 1,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: currentPage == lv - 1 ? Colors.red : Colors.white,
            ),
          ),
        ),
        child: Text(
          'กรุณาเลือกเหตุผล',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  _buildPageLv() {
    return ListView.separated(
      itemCount: _model.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Theme.of(context).backgroundColor,
      ),
      itemBuilder: (context, index) => _buildItem(_model[index]),
    );
  }

  StackTap _buildItem(item) {
    Color colorItem = Colors.black;
    return StackTap(
      onTap: () async => {
        Navigator.pop(context, {
          'title': item['title'],
        })
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item['title'] != null ? item['title'] : item['postCode'],
              style: TextStyle(
                  fontFamily: 'Kanit', fontSize: 14, color: colorItem),
            ),
            Icon(
              colorItem == Colors.red ? Icons.check : null,
              size: colorItem == Colors.red ? 20 : 15,
              color: colorItem,
            ),
          ],
        ),
      ),
    );
  }

  _callRead() async {}
}
