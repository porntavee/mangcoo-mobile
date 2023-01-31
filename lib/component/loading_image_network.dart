import 'package:flutter/material.dart';
import 'package:wereward/component/material/loading_tween.dart';

loadingImageNetwork(
  String url, {
  BoxFit fit,
  double height,
  double width,
  Color color,
  bool isProfile = false,
}) {
  if (url == null) url = '';
  if (url == '' && isProfile)
    return Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(
        'assets/images/user_not_found.png',
        color: Colors.white,
      ),
    );
  if (url == '') return LoadingTween(height: height, width: width);
  return Image.network(
    url,
    fit: fit,
    height: height,
    width: width,
    color: color,
    loadingBuilder:
        (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
          child: loadingProgress.expectedTotalBytes != null
              ? LoadingTween(height: height, width: width)
              // ColorLoader5(
              //     dotOneColor: Color(0xFFED5643),
              //     dotTwoColor: Colors.red,
              //     dotThreeColor: Color(0xFFED5643),
              //   )
              : Container());
    },
    errorBuilder:
        (BuildContext context, Object exception, StackTrace stackTrace) {
      return LoadingTween(height: height, width: width);
    },
  );
}
