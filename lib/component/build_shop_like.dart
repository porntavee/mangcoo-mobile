import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/form_content_shop.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class BuildShopLike extends StatefulWidget {
  BuildShopLike({Key key, this.model}) : super(key: key);

  final Future<dynamic> model;

  @override
  BuildShopLikeState createState() => BuildShopLikeState();
}

class BuildShopLikeState extends State<BuildShopLike> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        buildGrid(),
      ],
    );
  }

  buildGrid() {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return GridView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                // childAspectRatio: MediaQuery.of(context).size.width /
                //     (MediaQuery.of(context).size.height / 1.6),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                print(snapshot.data[index]);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    left: index % 2 != 0 ? 5 : 0,
                    right: index % 2 == 0 ? 5 : 0,
                  ),
                  child: buildCard(
                    model: snapshot.data[index],
                    index: index,
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: 4,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  buildCard({dynamic model, int index = 0, int lastIndex = 0}) {
    return StackTap(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        scaleTransitionNav(FormContentShop(
          api: 'poi',
          model: model,
          urlRotation: rotationNewsApi,
        ));
        Navigator.push(
            context,
            scaleTransitionNav(FormContentShop(
              api: 'goods',
              model: model,
              urlRotation: rotationNewsApi,
            ))
            // MaterialPageRoute(
            //   builder: (context) => FormContentShop(
            //     api: 'poi',
            //     model: model,
            //     urlRotation: rotationNewsApi,
            //   ),
            // ),
            );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          new BorderRadius.vertical(top: Radius.circular(8)),
                      child: loadingImageNetwork(
                        model['imageUrl'],
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (model['discount'] > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          height: 20,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 1,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            setTextDiscount(model),
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 10,
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
              padding: EdgeInsets.symmetric(horizontal: 10),
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
                            model['netPrice'] != null
                                ? priceFormat.format(model['netPrice']) + " บาท"
                                : '',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        child: Image.asset(
                          model['like']
                              ? 'assets/images/heart_full.png'
                              : 'assets/images/heart.png',
                          fit: BoxFit.contain,
                          color: model['like'] ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 35),
                    child: Text(
                      model['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Kanit',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  setTextDiscount(model) {
    String unit = '';
    String total =
        model['discount'] > 0 ? priceFormat.format(model['discount']) : '';
    if (total != '') unit = model['disCountUnit'] == 'C' ? ' บาท' : ' %';
    return total + unit;
  }
}
