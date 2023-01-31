import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GridContent1 extends StatefulWidget {
  GridContent1({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: 160,
    this.cardHeight: 250,
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
  _GridContent1 createState() => _GridContent1();
}

class _GridContent1 extends State<GridContent1> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return GridView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                // childAspectRatio: MediaQuery.of(context).size.width /
                //     (MediaQuery.of(context).size.height / 1.6),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),

              // gridDelegate:
              //     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),

              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    if (index % 2 != 0) SizedBox(width: 5),
                    Expanded(
                      child: _card(
                        model: snapshot.data[index],
                        index: index,
                        lastIndex: snapshot.data.length,
                      ),
                    ),
                    if (index % 2 == 0) SizedBox(width: 5)
                  ],
                );
              },
            );
          } else {
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
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
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
    String textHtml = model['description'];

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        // width: widget.cardWidth,
        // height: widget.cardHeight,
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
                    // Positioned(
                    //   top: 10,
                    //   left: 10,
                    //   child: Container(
                    //     padding: EdgeInsets.only(
                    //       left: 5,
                    //       right: 5,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //       color: Color(0xFFED6B2D),
                    //     ),
                    //     child: Text(
                    //       'แลกฟรี',
                    //       style: TextStyle(
                    //         fontFamily: 'Kanit',
                    //         fontSize: 11,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // )
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
                      Expanded(
                        child: Container(
                          child: Text(
                            model['createBy'],
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                      // SizedBox(width: 5),
                      // Container(
                      //   height: 20,
                      //   width: 20,
                      //   child: Image.asset(
                      //     'assets/images/bookmark.png',
                      //     fit: BoxFit.contain,
                      //   ),
                      // ),
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 35),
                    child: Text(
                      model['title'],
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Kanit',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
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

class GridContent2 extends StatefulWidget {
  GridContent2({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: 160,
    this.cardHeight: 250,
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
  _GridContent2 createState() => _GridContent2();
}

class _GridContent2 extends State<GridContent2> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return GridView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 1.75),
              ),

              // gridDelegate:
              //     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),

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
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GridView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
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
    EdgeInsets margin = index % 2 == 0
        ? EdgeInsets.only(left: 15, right: 7.5)
        : EdgeInsets.only(left: 7.5, right: 15);

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
                  Container(
                    constraints: BoxConstraints(minHeight: 35),
                    child: Text(
                      model['title'],
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
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
}

// Show 4 len
class GridContent3 extends StatefulWidget {
  GridContent3({
    Key key,
    this.title: '',
    this.model,
    this.cardWidth: 160,
    this.cardHeight: 250,
    this.hasImageCenter: false,
    this.hasDescription: false,
    this.rightButton,
    this.navigationList,
    this.navigationForm,
    this.itemCount: 0,
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
  final int itemCount;

  @override
  _GridContent3 createState() => _GridContent3();
}

class _GridContent3 extends State<GridContent3> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return GridView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                // childAspectRatio: MediaQuery.of(context).size.width /
                //     (MediaQuery.of(context).size.height / 1.6),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),

              // gridDelegate:
              //     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),

              itemCount: widget.itemCount > 0
                  ? widget.itemCount
                  : snapshot.data.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    if (index % 2 != 0) SizedBox(width: 5),
                    Expanded(
                      child: _card(
                        model: snapshot.data[index],
                        index: index,
                        lastIndex: 4,
                      ),
                    ),
                    if (index % 2 == 0) SizedBox(width: 5)
                  ],
                );
              },
            );
          } else {
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
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: widget.itemCount > 0 ? widget.itemCount : 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  _card({dynamic model, int index = 0, int lastIndex = 0}) {
    String textHtml = model['description'];

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        // width: widget.cardWidth,
        // height: widget.cardHeight,
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
                    // Positioned(
                    //   top: 10,
                    //   left: 10,
                    //   child: Container(
                    //     padding: EdgeInsets.only(
                    //       left: 5,
                    //       right: 5,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //       color: Color(0xFFED6B2D),
                    //     ),
                    //     child: Text(
                    //       'แลกฟรี',
                    //       style: TextStyle(
                    //         fontFamily: 'Kanit',
                    //         fontSize: 11,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // )
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
                      Expanded(
                        child: Container(
                          child: Text(
                            priceFormat.format(model['price']) + " บาท",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                      // SizedBox(width: 5),
                      // Container(
                      //   height: 20,
                      //   width: 20,
                      //   child: Image.asset(
                      //     'assets/images/bookmark.png',
                      //     fit: BoxFit.contain,
                      //   ),
                      // ),
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 35),
                    child: Text(
                      model['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Kanit',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
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
