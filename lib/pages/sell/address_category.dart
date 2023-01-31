import 'package:flutter/material.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class AddressCategoryPage extends StatefulWidget {
  const AddressCategoryPage({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _AddressCategoryPageState createState() => _AddressCategoryPageState();
}

class _AddressCategoryPageState extends State<AddressCategoryPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<AddressCategoryPage> {
  PageController pageController;

  int currentPage = 0;
  Future<dynamic> _futureShopLv1;
  Future<dynamic> _futureShopLv2;
  Future<dynamic> _futureShopLv3;
  Future<dynamic> _futureShopLv4;
  dynamic lv1 = [];

  String selectedCodeLv1 = '';
  String selectedCodeLv2 = '';
  String selectedCodeLv3 = '';
  String selectedCodeLv4 = '';

  String titleCategoryLv1 = '';
  String titleCategoryLv2 = '';
  String titleCategoryLv3 = '';
  String titleCategoryLv4 = '';

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
                  if (selectedCodeLv3 != '') _titleCategory(4),
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
                  if (selectedCodeLv3 != '') _buildPageLv(_futureShopLv4, 4),
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
      text = 'จังหวัด';
    }
    if (page == 2) {
      text = titleCategoryLv1;
    }
    if (page == 3) {
      text = titleCategoryLv2;
    }
    if (page == 4) {
      text = titleCategoryLv3;
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
    if (page == 4 && selectedCodeLv4 == item['postCode'])
      colorItem = Colors.red;
    return StackTap(
      onTap: () async => {
        if (page == 1)
          {
            selectedCodeLv1 = await item['code'],
            selectedCodeLv2 = '',
            selectedCodeLv3 = '',
            selectedCodeLv4 = '',
            titleCategoryLv1 = item['title'],
            getCategory(page),
            currentPage = page,
            pageController.animateToPage(page,
                duration: Duration(milliseconds: 500), curve: Curves.ease)
          },
        if (page == 2)
          {
            selectedCodeLv2 = await item['code'],
            selectedCodeLv3 = '',
            selectedCodeLv4 = '',
            titleCategoryLv2 = item['title'],
            getCategory(page),
            pageController.animateToPage(page,
                duration: Duration(milliseconds: 500), curve: Curves.ease)
          },
        if (page == 3)
          {
            selectedCodeLv3 = await item['code'],
            selectedCodeLv4 = '',
            titleCategoryLv3 = item['title'],
            getCategory(page),
            pageController.animateToPage(page,
                duration: Duration(milliseconds: 500), curve: Curves.ease)
          },
        if (page == 4)
          {
            Navigator.pop(context, {
              'provinceTitle': titleCategoryLv1,
              'provinceCode': selectedCodeLv1,
              'districtTitle': titleCategoryLv2,
              'districtCode': selectedCodeLv2,
              'subDistrictTitle': titleCategoryLv3,
              'subDistrictCode': selectedCodeLv3,
              'postCode': selectedCodeLv4,
              ...item
            })
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
              item['title'] != null ? item['title'] : item['postCode'],
              style: TextStyle(
                  fontFamily: 'Kanit', fontSize: 14, color: colorItem),
            ),
            Icon(
              colorItem == Colors.red
                  ? Icons.check
                  : page != 4
                      ? Icons.arrow_forward_ios_rounded
                      : null,
              size: colorItem == Colors.red ? 20 : 15,
              color: colorItem,
            ),
          ],
        ),
      ),
    );
  }

  _callRead() async {
    setState(
      () {
        _futureShopLv1 = postDio(server + 'route/province/read', {});

        if (widget.model['provinceTitle'] != "") {
          selectedCodeLv1 = widget.model['provinceCode'];
          titleCategoryLv1 = widget.model['provinceTitle'];

          _futureShopLv2 = postDio(server + 'route/district/read', {
            'province': selectedCodeLv1,
          });
          selectedCodeLv2 = widget.model['districtCode'];
          titleCategoryLv2 = widget.model['districtTitle'];

          _futureShopLv3 = postDio(server + "route/tambon/read", {
            'province': selectedCodeLv1,
            'district': selectedCodeLv2,
          });
          selectedCodeLv3 = widget.model['subDistrictCode'];
          titleCategoryLv3 = widget.model['subDistrictTitle'];

          _futureShopLv4 = postDio(server + "route/postcode/read", {
            'tambon': selectedCodeLv3,
          });
          selectedCodeLv4 = widget.model['postCode'];
          titleCategoryLv4 = widget.model['postalTitle'];
        } //
      },
    );
  }

  getCategory(lv) {
    setState(
      () {
        if (lv == 1)
          _futureShopLv2 = postDio(server + "route/district/read", {
            'province': selectedCodeLv1,
          });
        if (lv == 2)
          _futureShopLv3 = postDio(server + "route/tambon/read", {
            'province': selectedCodeLv1,
            'district': selectedCodeLv2,
          });
        if (lv == 3)
          _futureShopLv4 = postDio(server + "route/postcode/read", {
            'tambon': selectedCodeLv3,
          });
      },
    );
  }
}
