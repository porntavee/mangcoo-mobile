import 'package:flutter/material.dart';

scaleTransitionNav(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return child;
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
          ),
        ),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 500),
  );
}

fadeNav(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return child;
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
          ),
        ),
        child: child,
      );
    },
    transitionDuration: Duration(seconds: 1),
  );
}
