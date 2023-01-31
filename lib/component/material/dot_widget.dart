import 'package:flutter/material.dart';

// dash vertical
class DotVerticalWidget extends StatelessWidget {
  final double totalHeight, dashWidth, emptyHeight, dashHeight;

  final Color dashColor;

  const DotVerticalWidget({
    this.totalHeight = 160,
    this.dashWidth = 1,
    this.emptyHeight = 10,
    this.dashHeight = 5,
    this.dashColor = Colors.white,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalHeight ~/ (dashHeight + emptyHeight),
        (_) => Container(
          width: dashWidth,
          height: dashHeight,
          color: dashColor,
          margin:
              EdgeInsets.only(top: emptyHeight / 2, bottom: emptyHeight / 2),
        ),
      ),
    );
  }
}

// dash horizontal
class DotHorizonWidget extends StatelessWidget {
  final double totalWidth, dashWidth, emptyWidth, dashHeight;

  final Color dashColor;

  const DotHorizonWidget({
    this.totalWidth = 300,
    this.dashWidth = 10,
    this.emptyWidth = 5,
    this.dashHeight = 2,
    this.dashColor = Colors.black,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalWidth ~/ (dashWidth + emptyWidth),
        (_) => Container(
          width: dashWidth,
          height: dashHeight,
          color: dashColor,
          margin: EdgeInsets.only(left: emptyWidth / 2, right: emptyWidth / 2),
        ),
      ),
    );
  }
}
