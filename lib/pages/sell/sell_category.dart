import 'package:flutter/material.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class SellCategoryPage extends StatefulWidget {
  const SellCategoryPage({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _SellCategoryPageState createState() => _SellCategoryPageState();
}

class _SellCategoryPageState extends State<SellCategoryPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SellCategoryPage> {
  PageController pageController;

  int currentPage = 0;
  Future<dynamic> _futureShopLv1;
  Future<dynamic> _futureShopLv2;
  Future<dynamic> _futureShopLv3;
  dynamic lv1 = [];

  String selectedCodeLv1 = '';
  String selectedCodeLv2 = '';
  String selectedCodeLv3 = '';

  String titleCategoryLv1 = '';
  String titleCategoryLv2 = '';

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
                  if (selectedCodeLv1 != '') _titleCategory(2),
                  if (selectedCodeLv2 != '') _titleCategory(3),
                ],
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: new NeverScrollableScrollPhysics(),
                children: [
                  _buildPageLv(_futureShopLv1, 1),
                  if (selectedCodeLv1 != '') _buildPageLv(_futureShopLv2, 2),
                  if (selectedCodeLv2 != '') _buildPageLv(_futureShopLv3, 3),
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
          textCategory(lv),
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  textCategory(page) {
    String text = '';
    if (page == 1) {
      text = 'หมวดหมู่';
    }
    if (page == 2) {
      text = titleCategoryLv1;
    }
    if (page == 3) {
      text = titleCategoryLv2;
    }

    return text;
  }

  _buildPageLv(_future, lv) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            itemCount: snapshot.data.length,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: Theme.of(context).backgroundColor,
            ),
            itemBuilder: (context, index) =>
                _buildItem(snapshot.data[index], lv),
          );
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _callRead());
        } else {
          return ListView.separated(
            itemCount: 10,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: Theme.of(context).backgroundColor,
            ),
            itemBuilder: (context, index) => Container(
              height: 50,
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
            ),
          );
        }
      },
    );
  }

  StackTap _buildItem(item, page) {
    Color colorItem = Colors.black;
    if (page == 1 && selectedCodeLv1 == item['code']) colorItem = Colors.red;
    if (page == 2 && selectedCodeLv2 == item['code']) colorItem = Colors.red;
    if (page == 3 && selectedCodeLv3 == item['code']) colorItem = Colors.red;
    return StackTap(
      onTap: () async => {
        if (page == 3)
          Navigator.pop(context, {
            'titleLv1': titleCategoryLv1,
            'titleLv2': titleCategoryLv2,
            ...item
          }),
        if (page == 1)
          {
            selectedCodeLv1 = await item['code'],
            selectedCodeLv2 = '',
            selectedCodeLv3 = '',
            titleCategoryLv1 = item['title'],
            titleCategoryLv2 = '',
            getCategory(page),
            if (item['isHighlight'])
              Navigator.pop(context, {
                'code': selectedCodeLv1,
                'title': titleCategoryLv1,
                'category': 'lv1'
              })
            else
              {
                currentPage = page,
                pageController.animateToPage(page,
                    duration: Duration(milliseconds: 500), curve: Curves.ease)
              }
          },
        if (page == 2)
          {
            selectedCodeLv2 = await item['code'],
            selectedCodeLv3 = '',
            titleCategoryLv2 = item['title'],
            getCategory(page),
            if (item['isHighlight'])
              Navigator.pop(context, {
                'code': selectedCodeLv2,
                'title': titleCategoryLv2,
                'lv1': selectedCodeLv1,
                'titleLv1': titleCategoryLv1,
                'category': 'lv2'
              })
            else
              {
                currentPage = page,
                pageController.animateToPage(page,
                    duration: Duration(milliseconds: 500), curve: Curves.ease)
              }
          },
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
              item['title'],
              style: TextStyle(
                  fontFamily: 'Kanit', fontSize: 14, color: colorItem),
            ),
            Icon(
              colorItem == Colors.red
                  ? Icons.check
                  : page != 3 && !item['isHighlight']
                      ? Icons.arrow_forward_ios_rounded
                      : null,
              size: colorItem == Colors.red ? 20 : 15,
              color: colorItem,
            )
          ],
        ),
      ),
    );
  }

  _callRead() async {
    setState(
      () {
        _futureShopLv1 =
            postDio(server + 'm/mCategory/read', {'category': 'lv1'});

        if (widget.model['category'] == 'lv1') {
          selectedCodeLv1 = widget.model['code'];
        }

        if (widget.model['category'] == 'lv2') {
          selectedCodeLv1 = widget.model['lv1'];
          selectedCodeLv2 = widget.model['code'];

          titleCategoryLv1 = widget.model['titleLv1'];
          _futureShopLv2 = postDio(server + 'm/mCategory/read',
              {'category': 'lv2', 'lv1': selectedCodeLv1});
        }

        if (widget.model['category'] == 'lv3') {
          selectedCodeLv1 = widget.model['lv1'];
          selectedCodeLv2 = widget.model['lv2'];
          selectedCodeLv3 = widget.model['code'];

          titleCategoryLv1 = widget.model['titleLv1'];
          titleCategoryLv2 = widget.model['titleLv2'];

          _futureShopLv2 = postDio(server + 'm/mCategory/read',
              {'category': 'lv2', 'lv1': selectedCodeLv1});
          _futureShopLv3 = postDio(server + 'm/mCategory/read',
              {'category': 'lv3', 'lv2': selectedCodeLv2});
        }
      },
    );
  }

  getCategory(lv) {
    setState(
      () {
        if (lv == 1)
          _futureShopLv2 = postDio(server + 'm/mCategory/read',
              {'category': 'lv2', 'lv1': selectedCodeLv1});
        if (lv == 2)
          _futureShopLv3 = postDio(server + 'm/mCategory/read',
              {'category': 'lv3', 'lv2': selectedCodeLv2});
      },
    );
  }
}
