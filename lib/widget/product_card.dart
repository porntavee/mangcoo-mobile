import 'package:flutter/material.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/form_content_shop.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class ProductCard extends StatelessWidget {
  ProductCard({Key key, this.model, this.width}) : super(key: key);

  final dynamic model;
  final double width;

  @override
  Widget build(BuildContext context) {
    return StackTap(
      onTap: () {
        postDio(server + 'm/goods/history/create', {'code': model['code']});
        Navigator.push(
            context,
            scaleTransitionNav(FormContentShop(
              api: 'goods',
              model: model,
              urlRotation: rotationNewsApi,
            )));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          loadingImageNetwork(
            model['imageUrl'],
            fit: BoxFit.contain,
            width: width,
            height: width,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (model['discount'] != 0 && model['discount'] != null)
                    _buildDiscount(),
                  Text(
                    '฿ ' + priceFormat.format(model['netPrice']),
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 18,
                      color: Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (model['netPriceUsd'] != null)
                    if (model['netPrice'] != model['netPriceUsd'])
                      Text(
                        '\$ ' + priceFormat.format(model['netPriceUsd']),
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                          color: Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/heart.png',
                        width: 15,
                        height: 15,
                      ),
                      SizedBox(width: 3),
                      ratingBar(model['rating']),
                      SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          'ขายได้ 1 ชิ้น',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Icon(
                  //       Icons.location_on,
                  //       size: 11,
                  //     ),
                  //     Text(
                  //       'กรุงเทพฯ',
                  //       style: TextStyle(
                  //         fontFamily: 'Kanit',
                  //         fontSize: 10,
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildDiscount() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.red),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        setTextDiscount(),
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 9,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget ratingBar(param) {
    const starFull = 'assets/images/star_full.png';
    const starHalf = 'assets/images/star_half_empty.png';
    const starEmpty = 'assets/images/star_empty.png';

    if (param == null) param = 0;
    var rating = double.parse(param.toString());
    if (rating == 0)
      return Row(
        children: [0, 1, 2, 3, 4]
            .map((e) => Image.asset(starEmpty, height: 15, width: 15))
            .toList(),
      );

    var strStar = new List<String>();

    for (int i = 1; i <= 5; i++) {
      double decimalRating = i - rating;

      if (decimalRating > 0 && decimalRating < 1) {
        strStar.add(starHalf);
      } else {
        if (i <= rating) {
          strStar.add(starFull);
        } else {
          strStar.add(starEmpty);
        }
      }
    }
    return Row(
      children:
          strStar.map((e) => Image.asset(e, height: 15, width: 15)).toList(),
    );
  }

  setTextDiscount() {
    String unit = '';
    String total =
        model['discount'] > 0 ? priceFormat.format(model['discount']) : '';
    if (total != '') unit = model['disCountUnit'] == 'C' ? ' บาท' : ' %';
    return total + unit;
  }
}
