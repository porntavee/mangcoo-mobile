import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shop.dart';

class ShopListPage extends StatefulWidget {
  ShopListPage({Key key, this.code}) : super(key: key);

  final String code;
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopListPage> {
  Future<dynamic> futureModel;
  ScrollController _scrollController;

  @override
  void initState() {
    _callInitial();
    super.initState();
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
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: _callRefreshData,
          child: ListView(
            controller: _scrollController,
            // padding: EdgeInsets.zero,
            children: [
              _buildFutureGridViewMapProduct(context, futureModel),
            ],
          ),
        ),
      ),
    );
  }

  _buildAppBar() {
    return new PreferredSize(
      child: new Container(
        padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            new Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: Image.asset(
                  // 'assets/we_mart.png',
                  // height: 30,
                  'assets/suksapan-online.png',
                  height: 50,
                )
                // new Text(
                //   'We Mall',
                //   style: new TextStyle(
                //       fontSize: 20.0,
                //       fontWeight: FontWeight.w500,
                //       color: Colors.white),
                // ),
                ),
          ],
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
          boxShadow: [
            new BoxShadow(
              color: Colors.grey[500],
              blurRadius: 20.0,
              spreadRadius: 1.0,
            )
          ],
        ),
      ),
      preferredSize: new Size(MediaQuery.of(context).size.width, 150.0),
    );
  }

  _buildFutureGridViewMapProduct(BuildContext context, Future<dynamic> param) {
    return FutureBuilder<dynamic>(
      future: param,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return GridView.count(
            shrinkWrap: true, // 1st add
            physics: ClampingScrollPhysics(), // 2nd
            primary: false,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            childAspectRatio: 1,
            children: snapshot.data
                .map<Widget>(
                  (item) => GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => ShopPage(
                                model: item,
                              ),
                            ),
                          )
                          .then((value) => setState(() {
                                futureModel =
                                    postDio('${server}m/shop/read', {});
                              }));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            children: [
                              Expanded(
                                // flex: 3,
                                child: Image.network(
                                  item['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              height: 25,
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // alignment: Alignment.topRight,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellowAccent,
                                  ),
                                  Text(
                                    'แนะนำ',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Container(
                              padding:
                                  EdgeInsets.only(top: 7, left: 5, right: 5),
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              // alignment: Alignment.topRight,
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('E'));
        } else {
          return Center(child: Text('Loading...'));
        }
      },
    );
  }

  Future _callRefreshData() async {
    await Future.delayed(Duration(seconds: 1));
    // _data.clear();
    // _data.addAll(generateWordPairs().take(20));
    // setState(() {});
    _callInitial();
  }

  _callInitial() async {
    // print('start');
    futureModel = postDio('${server}m/shop/read', {});
  }
}
