import 'dart:async';

import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/data_not_found.dart';
import 'package:wereward/component/material/dot_widget.dart';
import 'package:wereward/component/material/get_map.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/promotion.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable รูปข้างบน หัวข้อกับคำอธิบายข้างล่าง (horizontal, กำหนดขนาด)
class ListContentFullImageHorizontal extends StatefulWidget {
  ListContentFullImageHorizontal(
      {Key key,
      this.title,
      this.model,
      this.cardWidth,
      this.navigationList,
      this.hasImageCenter,
      this.hasDescription,
      this.rightButton,
      this.navigationForm})
      : super(key: key);

  final String title;
  final double cardWidth;
  final Widget rightButton;
  final bool hasImageCenter;
  final bool hasDescription;
  final Future<dynamic> model;
  final Function() navigationList;
  final Function(dynamic) navigationForm;

  @override
  _ListContentFullImageHorizontal createState() =>
      _ListContentFullImageHorizontal();
}

class _ListContentFullImageHorizontal
    extends State<ListContentFullImageHorizontal> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    double height =
        widget.hasDescription != null && widget.hasDescription ? 260 : 220;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      constraints: BoxConstraints(
        minHeight: 210,
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 15),
            margin: EdgeInsets.only(bottom: 5),
            child: Text(
              widget.title,
              style: TextStyle(
                color: themeChange.darkTheme
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                fontSize: 13,
                fontFamily: 'Kanit',
              ),
            ),
          ),
          Container(
            height: height,
            color: Colors.transparent,
            child: renderCard(),
          ),
        ],
      ),
    );
  }

  renderCard() {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return myCard(
                model: snapshot.data[index],
                index: index,
                lastIndex: snapshot.data.length,
              );
            },
          );
          // } else if (snapshot.hasError) {
          //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  myCard({dynamic model, int index = 0, int lastIndex = 0}) {
    EdgeInsets margin = index == 0
        ? EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 5.0)
        : index == lastIndex - 1
            ? EdgeInsets.only(left: 5.0, bottom: 5.0, top: 5.0, right: 10.0)
            : EdgeInsets.all(5);

    String textHtml = model['description'];

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        width: widget.cardWidth,
        height: 200,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.white,
                // image: DecorationImage(
                //   fit: BoxFit.fill,
                //   image:  NetworkImage(model['imageUrl']),
                // ),
              ),
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: loadingImageNetwork(
                  model['imageUrl'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            widget.hasImageCenter ? cycleImageCenter(model) : Container(),
            Container(
              margin: EdgeInsets.only(top: 160),
              padding: EdgeInsets.only(left: 5, right: 5),
              alignment: Alignment.topCenter,
              // height: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Kanit',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 5),
                  if (widget.hasDescription != null && widget.hasDescription)
                    Text(
                      '5 Point',
                      style: TextStyle(color: Colors.orange),
                      textAlign: TextAlign.start,
                    ),
                  if (widget.hasDescription != null && widget.hasDescription)
                    Row(
                      children: [
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            toastFail(context);
                          },
                          child: Container(
                            height: 25,
                            width: 20,
                            child: Image.asset(
                              'assets/images/heart.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            parseHtmlString(textHtml),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textSelectionHandleColor,
                              fontFamily: 'Kanit',
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  cycleImageCenter(dynamic model) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      alignment: Alignment.topCenter,
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Colors.red)),
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(20.0),
              child: loadingImageNetwork(
                model['imageUrlCreateBy'],
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable รูปข้างบน หัวข้อข้างล่าง มีปุ่มหัวใจ (horizontal, กำหนดขนาด)
class ListReward extends StatefulWidget {
  ListReward({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: 160,
    this.cardHeight: 200,
    this.hasImageCenter: false,
    this.hasDescription: false,
    this.rightButton,
    this.navigationList,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final double cardWidth;
  final double cardHeight;
  final Widget rightButton;
  final bool hasImageCenter;
  final bool hasDescription;
  final Future<dynamic> model;
  final Function() navigationList;
  final Function(dynamic) navigationForm;

  @override
  _ListReward createState() => _ListReward();
}

class _ListReward extends State<ListReward> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      constraints: BoxConstraints(
        minHeight: widget.cardHeight + 40,
        minWidth: widget.cardWidth,
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 15),
            margin: EdgeInsets.only(bottom: 5),
            child: Text(
              widget.title,
              style: TextStyle(
                color: themeChange.darkTheme
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                fontSize: 13,
                fontFamily: 'Kanit',
              ),
            ),
          ),
          Container(
            height: widget.cardHeight,
            color: Colors.transparent,
            child: _listCard(),
          ),
        ],
      ),
    );
  }

  _listCard() {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return _card(
                model: snapshot.data[index],
                index: index,
                lastIndex: snapshot.data.length,
              );
            },
          );
          // } else if (snapshot.hasError) {
          //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    EdgeInsets margin = index == 0
        ? EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 5.0)
        : index == lastIndex - 1
            ? EdgeInsets.only(left: 5.0, bottom: 5.0, top: 5.0, right: 10.0)
            : EdgeInsets.all(5);

    String textHtml = model['description'];

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        width: widget.cardWidth,
        height: widget.cardHeight,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                ),
                // image: DecorationImage(
                //   fit: BoxFit.fill,
                //   image:  NetworkImage(model['imageUrl']),
                // ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      child: loadingImageNetwork(
                        model['imageUrl'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                    widget.hasImageCenter
                        ? cycleImageCenter(model)
                        : Container(),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFED6B2D),
                        ),
                        child: Text(
                          '',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          toastFail(context);
                        },
                        child: Container(
                          height: 25,
                          width: 20,
                          child: Image.asset(
                            'assets/images/heart.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFED6B2D),
                        ),
                        child: Text(
                          'แลกเลย',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 5),
                  if (widget.hasDescription != null && widget.hasDescription)
                    Text(
                      '5 Point',
                      style: TextStyle(color: Colors.orange),
                      textAlign: TextAlign.start,
                    ),
                  if (widget.hasDescription != null && widget.hasDescription)
                    Row(
                      children: [
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            toastFail(context);
                          },
                          child: Container(
                            height: 25,
                            width: 20,
                            child: Image.asset(
                              'assets/images/heart.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            parseHtmlString(textHtml),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textSelectionHandleColor,
                              fontFamily: 'Kanit',
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  cycleImageCenter(dynamic model) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      alignment: Alignment.topCenter,
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Colors.red)),
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(20.0),
              child: loadingImageNetwork(
                model['imageUrlCreateBy'],
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable รูปข้างบน หัวข้อกับคำอธิบายข้างล่าง (vertical, ความยาวยืดสุดยืดสุด)
class ListVertical extends StatefulWidget {
  ListVertical({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: 160,
    this.cardHeight: 200,
    this.hasImageCenter: false,
    this.hasDescription: false,
    this.rightButton,
    this.navigationList,
    this.navigationForm,
    this.callBackRefresh,
  }) : super(key: key);

  final String title;
  final double cardWidth;
  final double cardHeight;
  final Widget rightButton;
  final bool hasImageCenter;
  final bool hasDescription;
  final Future<dynamic> model;
  final Function() navigationList;
  final Function(dynamic) navigationForm;
  final Function callBackRefresh;

  @override
  _ListVertical createState() => _ListVertical();
}

class _ListVertical extends State<ListVertical> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _card(
                  model: snapshot.data[index],
                  index: index,
                  lastIndex: snapshot.data.length,
                );
              },
            );
          } else {
            return DataNotFound();
          }
        } else if (snapshot.hasError) {
          return Center(
              child: Column(
            children: [
              SizedBox(height: 50),
              Text(
                'เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง',
                style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
              ),
              SizedBox(height: 30),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => widget.callBackRefresh(),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.refresh,
                    size: 40,
                  ),
                ),
              ),
            ],
          ));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    EdgeInsets margin = EdgeInsets.all(15);

    String textHtml = model['description'];

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        width: widget.cardWidth,
        height: widget.cardHeight,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                ),
                // image: DecorationImage(
                //   fit: BoxFit.fill,
                //   image:  NetworkImage(model['imageUrl']),
                // ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      child: loadingImageNetwork(
                        model['imageUrl'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                    widget.hasImageCenter
                        ? cycleImageCenter(model)
                        : Container(),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFED6B2D),
                        ),
                        child: Text(
                          model['categoryTitle'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          model['like']
                              ? 'assets/images/heart_full.png'
                              : 'assets/images/heart.png',
                          fit: BoxFit.contain,
                          color: model['like'] ? Colors.red : Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model['title'],
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            parseHtmlString(textHtml),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textSelectionHandleColor,
                              fontFamily: 'Kanit',
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      )),
                    ],
                  ),
                  SizedBox(height: 5),
                  if (widget.hasDescription != null && widget.hasDescription)
                    Text(
                      '5 Point',
                      style: TextStyle(color: Colors.orange),
                      textAlign: TextAlign.start,
                    ),
                  if (widget.hasDescription != null && widget.hasDescription)
                    Row(
                      children: [
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            toastFail(context);
                          },
                          child: Container(
                            height: 25,
                            width: 20,
                            child: Image.asset(
                              'assets/images/heart.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            parseHtmlString(textHtml),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textSelectionHandleColor,
                              fontFamily: 'Kanit',
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  cycleImageCenter(dynamic model) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      alignment: Alignment.topCenter,
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Colors.red)),
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(20.0),
              child: loadingImageNetwork(
                model['imageUrlCreateBy'],
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable รูปข้างบน หัวข้อกับคำอธิบายข้างล่าง (vertical, ความยาวยืดสุดยืดสุด)
class ListCoupon extends StatefulWidget {
  ListCoupon(
      {Key key,
      this.title: '',
      this.model,
      this.category: 0,
      this.cardWidth: double.infinity,
      this.cardHeight: 150,
      this.navigationForm,
      })
      : super(key: key);

  final String title;
  final int category;
  final double cardWidth;
  final double cardHeight;
  final Future<dynamic> model;
  final Function(dynamic) navigationForm;

  @override
  _ListCoupon createState() => _ListCoupon();
}

class _ListCoupon extends State<ListCoupon> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _card(
                  model: snapshot.data[index],
                  index: index,
                  lastIndex: snapshot.data.length,
                );
              },
            );
          } else {
            // return DataNotFound();
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [                 
                  SizedBox(height: 40),
                  Text(
                    'คูปองยังว่างอยู่ เลือกหาคูปองได้ที่นี่',
                    style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
                  ),
                  SizedBox(height: 15),
                  Image.asset(
                    'assets/images/coupon.png',
                    height: 80,
                    width: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 15),
                  InkWell(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeMartPage(
                          pageIndex: 1,
                        ),
                      ),
                    ),                  
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      child: Text(
                        'เลือกตอนนี้',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง'),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    EdgeInsets margin = EdgeInsets.symmetric(horizontal: 15, vertical: 5);

    String textHtml = model['description'];
    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          // color: Colors.white,
          color: themeChange.darkTheme ? Color(0xFF707070) : Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.2),
          //     spreadRadius: 0,
          //     blurRadius: 6,
          //     offset: Offset(0, 3),
          //   ),
          // ],
        ),
        width: widget.cardWidth,
        height: widget.cardHeight,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: model['imageUrlCreateBy'] != null
                                ? NetworkImage(model['imageUrlCreateBy'])
                                : null,
                            radius: 15,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  model['createBy'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          model['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 80),
                        child: Text(
                          parseHtmlString(textHtml),
                          style: TextStyle(
                            fontSize: 11,
                            // color: Theme.of(context).textSelectionHandleColor,
                            fontFamily: 'Kanit',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.category == 1)
              Positioned(
                top: 10,
                right: 0,
                child: Container(
                  child: Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).accentColor,
                    ),
                    child: Image.asset('assets/images/heart.png',
                        color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              bottom: 10,
              right: 0,
              child: Container(
                constraints: BoxConstraints(minWidth: 50),
                child: Container(
                  height: 30,
                  width: 75,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: widget.category == 2
                          ? Color(0xFF707070)
                          : widget.category == 3
                              ? Colors.transparent
                              : Theme.of(context).primaryColor),
                  child: Text(
                    widget.category == 2
                        ? 'ใช้แล้ว'
                        : widget.category == 3
                            ? ''
                            : 'รับสิทธิ์',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable รูปข้างบน หัวข้อกับคำอธิบายข้างล่าง (vertical, ความยาวยืดสุดยืดสุด)

class ListOrderList extends StatefulWidget {
  ListOrderList({
    Key key,
    this.title: '',
    this.model,
    this.category: 0,
    this.cardWidth: double.infinity,
    // this.cardHeight: 150,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final int category;
  final double cardWidth;
  // final double cardHeight;
  final Future<dynamic> model;
  final Function(dynamic) navigationForm;

  @override
  _ListOrderList createState() => _ListOrderList();
}

class _ListOrderList extends State<ListOrderList> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _card(
                  model: snapshot.data[index],
                  index: index,
                  lastIndex: snapshot.data.length,
                );
              },
            );
          } else {
            return DataNotFound();
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง'),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 16, right: 15, left: 15),
        margin: EdgeInsets.only(bottom: 2.5, top: 2.5),
        color: Color(0xFFFFFFFF),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF10BC37),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 20,
                child: Text(
                  'เสร็จสิ้น',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontFamily: 'Kanit',
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF10BC37),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 100,
                      // color: Color(0xFF10BC37),
                      child: Column(
                        children: [
                          Expanded(
                            child: Text(
                              'เคสกันรอย Iphone15 ของแท้นำเข้าจาก USA มีของในสต๊อกพร้อมส่งทั่วประเทศ',
                              style: TextStyle(
                                color: Color(0xFF0000000),
                                fontFamily: 'Kanit',
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '100',
                                style: TextStyle(
                                  color: Color(0xFF707070),
                                  fontFamily: 'Kanit',
                                  fontSize: 15,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                '90 บาท',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontFamily: 'Kanit',
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.only(right: 7, left: 8),
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Color(0xFF707070), width: 1),
                                ),
                                child: Text(
                                  'เขียนรีวิว',
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontFamily: 'Kanit',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.only(right: 7, left: 8),
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Color(0xFF707070), width: 1),
                                ),
                                child: Text(
                                  'สั่งสินค้าอีกครั้ง',
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontFamily: 'Kanit',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ListRedeem extends StatefulWidget {
  ListRedeem({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: double.infinity,
    this.cardHeight: 150,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final double cardWidth;
  final double cardHeight;
  final Future<dynamic> model;
  final Function(dynamic) navigationForm;

  @override
  _ListRedeem createState() => _ListRedeem();
}

class _ListRedeem extends State<ListRedeem> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          // if (snapshot.data['status'] == 'F') return DataNotFound();
          if (snapshot.data.length > 0) {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _card(
                  model: snapshot.data[index],
                  index: index,
                  lastIndex: snapshot.data.length,
                );
              },
            );
          } else {
            return DataNotFound();
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: false),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    EdgeInsets margin = EdgeInsets.symmetric(horizontal: 15, vertical: 5);

    // String textHtml = model['description'];

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: widget.cardWidth,
        height: widget.cardHeight,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: model['imageUrlCreateBy'] != null
                                ? NetworkImage(model['imageUrlCreateBy'])
                                : null,
                            radius: 15,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  model['createBy'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 75),
                        child: Text(
                          model['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(right: 80),
                      //   child: Text(
                      //     parseHtmlString(textHtml),
                      //     style: TextStyle(
                      //       fontSize: 11,
                      //       // color: Theme.of(context).textSelectionHandleColor,
                      //       fontFamily: 'Kanit',
                      //     ),
                      //     overflow: TextOverflow.ellipsis,
                      //     maxLines: 3,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 0,
              child: Container(
                constraints: BoxConstraints(minWidth: 50),
                child: Container(
                  height: 30,
                  width: 75,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: model['status'] == 'A'
                        ? Color(0xFFE84C10)
                        : Color(0xFF707070),
                  ),
                  child: Text(
                    model['status'] == 'A' ? 'ยืนยันสิทธิ์' : 'ใช้แล้ว',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable รูปด้านซ้าย หัวข้อกับคำอธิบายด้านขวา (vertical, ความยาวยืดสุดยืดสุด)
class ListVertical1 extends StatefulWidget {
  ListVertical1({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: 160,
    this.cardHeight: 160,
    this.hasImageCenter: false,
    this.hasDescription: false,
    this.rightButton,
    this.navigationList,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final double cardWidth;
  final double cardHeight;
  final Widget rightButton;
  final bool hasImageCenter;
  final bool hasDescription;
  final Future<dynamic> model;
  final Function() navigationList;
  final Function(dynamic) navigationForm;

  @override
  _ListVertical1 createState() => _ListVertical1();
}

class _ListVertical1 extends State<ListVertical1> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _card(
                  model: snapshot.data[index],
                  index: index,
                  lastIndex: snapshot.data.length,
                );
              },
            );
          } else {
            return DataNotFound();
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: false),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    EdgeInsets margin = EdgeInsets.symmetric(vertical: 5);

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: Theme.of(context).accentColor,
        ),
        width: widget.cardWidth,
        height: widget.cardHeight,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(10),
                ),
                // image: DecorationImage(
                //   fit: BoxFit.fill,
                //   image:  NetworkImage(model['imageUrl']),
                // ),
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(8.0),
                  child: loadingImageNetwork(
                    model['imageUrl'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Container(
              width: 15,
              height: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  DotVerticalWidget(
                    dashColor: Colors.white,
                    dashHeight: 10,
                    dashWidth: 1,
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      height: 7.5,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 7.5,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 148,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/shop.png',
                    height: 30,
                    width: 30,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5),
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 15,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      color: Colors.white,
                    ),
                    child: Text(
                      'แลกเลย',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 11,
                        color: Theme.of(context).accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ใช้ได้ถึง 31 ธันวาคม 2564',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 7,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  cycleImageCenter(dynamic model) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      alignment: Alignment.topCenter,
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Colors.red)),
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(20.0),
              child: loadingImageNetwork(
                model['imageUrlCreateBy'],
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable รูปฝั่งซ้าย หัวข้อกับคำอธิบายฝั่งขวา (vertical, ความยาวยืดสุดยืดสุด)
class ListContent2 extends StatefulWidget {
  ListContent2({
    Key key,
    this.title: '',
    this.model,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final Future<dynamic> model;
  final Function(dynamic) navigationForm;

  @override
  _ListContent2 createState() => _ListContent2();
}

class _ListContent2 extends State<ListContent2> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.only(bottom: 15),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _card(
                  model: snapshot.data[index],
                  index: index,
                  lastIndex: snapshot.data.length,
                );
              },
            );
          } else {
            return DataNotFound();
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: false),
            ),
          );
        } else {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    String textHtml = model['description'] != null && model['description'] != ''
        ? model['description']
        : '';
    EdgeInsets margin = EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        width: double.infinity,
        height: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: new BorderRadius.circular(8.0),
              child: loadingImageNetwork(
                model['imageUrl'],
                width: 120,
                height: 120,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      model['title'],
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      parseHtmlString(textHtml),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textSelectionHandleColor,
                        fontFamily: 'Kanit',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable รูปฝั่งซ้าย หัวข้อกับคำอธิบายฝั่งขวา + collapse (vertical, ความยาวยืดสุด,กดเพื่อแสดงแผนที่)
class ListContent3 extends StatefulWidget {
  ListContent3({
    Key key,
    this.title: '',
    this.model,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final Future<dynamic> model;
  final Function(dynamic) navigationForm;

  @override
  _ListContent3 createState() => _ListContent3();
}

class _ListContent3 extends State<ListContent3>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<ListContent3> {
  bool showMap = false;
  var listShowMap;

  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    listShowMap = List<bool>();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(bottom: 15),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              listShowMap.add(false);
              return _card(
                model: snapshot.data[index],
                index: index,
                lastIndex: snapshot.data.length,
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง'),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(bottom: 15),
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    String textHtml = model['description'] != null && model['description'] != ''
        ? model['description']
        : '';
    EdgeInsets margin = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    double latitude = model['latitude'] != '' && model['latitude'] != null
        ? double.parse(model['latitude'])
        : 0.0;
    double longitude = model['longitude'] != '' && model['longitude'] != null
        ? double.parse(model['longitude'])
        : 0.0;
    return Column(
      children: [
        InkWell(
          onTap: () {
            // widget.navigationForm(model);
            setState(() {
              listShowMap[index] = !listShowMap[index];
            });
          },
          child: new Container(
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(5),
              color: Colors.transparent,
            ),
            width: double.infinity,
            height: 100,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: new BorderRadius.circular(5.0),
                  child: loadingImageNetwork(
                    model['imageUrl'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          model['title'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: Text(
                          parseHtmlString(textHtml),
                          style: TextStyle(
                            fontSize: 13,
                            // color: Theme.of(context).textSelectionHandleColor,
                            color: Color(0xFF000000),
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: 5),
                if (latitude != 0.0 && longitude != 0.0)
                  new Container(
                    padding: EdgeInsets.all(2),
                    alignment: Alignment.topCenter,
                    child: new Icon(
                      listShowMap[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color:
                          themeChange.darkTheme ? Colors.white : Colors.black,
                      size: 35,
                    ),
                  )
              ],
            ),
          ),
        ),
        SizedBox(height: 5),
        if (listShowMap[index])
          if (latitude != 0.0 && longitude != 0.0)
            Container(
              height: 200,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: GetMapFull(
                  model: model,
                  latLng: LatLng(latitude, longitude),
                ),
              ),
            ),
        SizedBox(height: 5),
      ],
    );
  }
}

// ignore: must_be_immutable รูปฝั่งซ้าย หัวข้อกับคำอธิบายฝั่งขวา (vertical, ความยาวยืดสุดยืดสุด)
class ListContent4 extends StatefulWidget {
  ListContent4({
    Key key,
    this.title: '',
    this.model,
    this.height: 160,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final double height;
  final Future<dynamic> model;
  final Function(dynamic) navigationForm;

  @override
  _ListContent4 createState() => _ListContent4();
}

class _ListContent4 extends State<ListContent4> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: FutureBuilder<dynamic>(
        future: widget.model, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              // padding: EdgeInsets.only(bottom: 15),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _card(
                  model: snapshot.data[index],
                  index: index,
                  lastIndex: snapshot.data.length,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListContentHorizontalLoading();
              },
            );
          }
        },
      ),
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    String textHtml = model['description'] != null && model['description'] != ''
        ? model['description']
        : '';
    EdgeInsets margin = EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        width: 120,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                ),
                // image: DecorationImage(
                //   fit: BoxFit.fill,
                //   image:  NetworkImage(model['imageUrl']),
                // ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      child: loadingImageNetwork(
                        model['imageUrl'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable รูปข้างบน หัวข้อข้างล่าง (circle ,horizontal, กำหนดขนาด)
class ListCircle extends StatefulWidget {
  ListCircle({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: 90,
    this.cardHeight: 130,
    this.hasImageCenter: false,
    this.hasDescription: false,
    this.rightButton,
    this.navigationList,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final double cardWidth;
  final double cardHeight;
  final Widget rightButton;
  final bool hasImageCenter;
  final bool hasDescription;
  final Future<dynamic> model;
  final Function() navigationList;
  final Function(dynamic, bool) navigationForm;

  @override
  _ListCircle createState() => _ListCircle();
}

class _ListCircle extends State<ListCircle> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      constraints: BoxConstraints(
        minHeight: widget.cardHeight + 40,
        minWidth: widget.cardWidth,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15),
                margin: EdgeInsets.only(bottom: 5),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: themeChange.darkTheme
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontSize: 13,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              // InkWell(
              //   onTap: () {
              //     widget.navigationList();
              //   },
              //   child: Container(
              //     alignment: Alignment.centerLeft,
              //     padding: EdgeInsets.only(right: 15),
              //     margin: EdgeInsets.only(bottom: 5),
              //     child: Text(
              //       'ดูทั้งหมด',
              //       style: TextStyle(
              //         fontSize: 13,
              //         fontFamily: 'Kanit',
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          Container(
            height: widget.cardHeight,
            color: Colors.transparent,
            child: _listCard(),
          ),
        ],
      ),
    );
  }

  _listCard() {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return _card(
                model: snapshot.data[index],
                index: index,
                lastIndex: snapshot.data.length,
              );
            },
          );
          // } else if (snapshot.hasError) {
          //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    EdgeInsets margin = index == 0
        ? EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 5.0)
        : index == lastIndex - 1
            ? EdgeInsets.only(left: 5.0, bottom: 5.0, top: 5.0, right: 10.0)
            : EdgeInsets.all(5);

    String textHtml = model['description'];

    return GestureDetector(
      onTap: () {
        widget.navigationForm(model, false);
      },
      onLongPressStart: (value) {
        widget.navigationForm(model, true);
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // borderRadius: new BorderRadius.circular(45),
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(45),
              child: loadingImageNetwork(
                model['imageUrl'],
                width: 90,
                height: 90,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: 100,
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              alignment: Alignment.topCenter,
              child: Text(
                model['title'],
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          )
        ],
      ),
    );
  }

  cycleImageCenter(dynamic model) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      alignment: Alignment.topCenter,
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Colors.red)),
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(20.0),
              child: loadingImageNetwork(
                model['imageUrlCreateBy'],
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
