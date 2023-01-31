import 'package:flutter/material.dart';

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..lineTo(0.0, size.height - 100)
      ..quadraticBezierTo(
          size.width / 6, size.height, size.width / 2, size.height - 55)
      ..quadraticBezierTo(size.width - (size.width / 6), size.height - 110,
          size.width, size.height - 60)
      ..lineTo(size.width, 0.0)
      ..close();

    // ..quadraticBezierTo(
    //     size.width / 4, size.height - 30, size.width / 2, size.height - 60)
    // ..quadraticBezierTo(size.width - (size.width / 4), size.height - 100,
    //     size.width, size.height - 30)

    // ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
    //     controlPoint2.dy, endPoint.dx, endPoint.dy)

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DolDurmaClipper extends CustomClipper<Path> {
  DolDurmaClipper({@required this.right, @required this.holeRadius});

  final double right;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - right - holeRadius, 0.0)
      ..arcToPoint(
        Offset(size.width - right, 0),
        clockwise: false,
        radius: Radius.circular(1),
      )
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - right, size.height)
      ..arcToPoint(
        Offset(size.width - right - holeRadius, size.height),
        clockwise: false,
        radius: Radius.circular(1),
      );

    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DolDurmaClipper oldClipper) => true;
}

class CustomHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = new Path();
    path.lineTo(0.0, size.height / 2);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
