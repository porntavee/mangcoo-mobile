import 'dart:async';

import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/form_content_shop.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wereward/widget/nav_animation.dart';

// ignore: must_be_immutable รูปข้างบน หัวข้อกับคำอธิบายข้างล่าง (horizontal, กำหนดขนาด)
class ListContentSameProduct extends StatefulWidget {
  ListContentSameProduct(
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
  _ListContentSameProduct createState() => _ListContentSameProduct();
}

class _ListContentSameProduct extends State<ListContentSameProduct>
    with WidgetsBindingObserver {
  bool like = false;

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
    double height = 240;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 250,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Theme.of(context).backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 15),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 15),
            margin: EdgeInsets.only(bottom: 5),
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
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
    like = model['like'];

    return InkWell(
      onTap: () {
        // widget.navigationForm(model);
        postDio(server + 'm/goods/history/create', {'code': model['code']});
        Navigator.push(
          context,
          scaleTransitionNav(
            FormContentShop(
              api: 'goods',
              model: model,
              urlRotation: rotationNewsApi,
            ),
          ),
        );
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        width: widget.cardWidth,
        height: 250,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 150,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${priceFormat.format(model['price']) + " บาท"}',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Kanit',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 5),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                like = !like;
                              });
                              postDio(
                                server + 'm/like/check',
                                {
                                  'reference': model['code'],
                                  'isActive': like,
                                  'category': model['category'],
                                },
                              );
                            },
                            child: Image.asset(
                              like
                                  ? 'assets/images/heart_full.png'
                                  : 'assets/images/heart.png',
                              height: 15,
                              width: 15,
                              color: like ? Colors.red : Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      parseHtmlString(textHtml),
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
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
