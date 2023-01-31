import 'package:wereward/component/menu/custom_clipper.dart';
import 'package:flutter/material.dart';

class FlexiableBannerAppBar extends StatelessWidget {
  FlexiableBannerAppBar({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          child: Container(
            color: Colors.white,
          ),
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
        ),
        Positioned(
          child: ClipPath(
            clipper: MyCustomClipper(),
            child: Container(
              height: 260,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor,
                  ],
                ),
              ),
            ),
          ),
          top: 0,
          left: 0,
          right: 0,
        ),
        Positioned(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                // height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: child,
              ),
            ],
          ),
          top: 10,
          left: 0,
          right: 0,
        ),
      ],
    );
  }
}

class FlexiableGridAppBar extends StatelessWidget {
  FlexiableGridAppBar({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          child: Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor,
                ],
              ),
            ),
          ),
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
        ),
        Positioned(
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          bottom: -1,
          left: 0,
          right: 0,
        ),
        Positioned(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: child,
              ),
            ],
          ),
          top: 20,
          // bottom: -10,
          left: 0,
          right: 0,
        ),
      ],
    );
  }
}
