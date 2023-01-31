import 'package:flutter/material.dart';

class ListContentHorizontalLoading extends StatefulWidget {
  // CardLoading({Key key, this.title}) : super(key: key);

  // final String title;

  @override
  _ListContentHorizontalLoading createState() =>
      _ListContentHorizontalLoading();
}

class _ListContentHorizontalLoading extends State<ListContentHorizontalLoading>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  dispose() {
    _controller.dispose(); // you need this
    super.dispose();
  }

  Animatable<Color> background = TweenSequence<Color>([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.black.withAlpha(20),
        end: Colors.black.withAlpha(50),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.black.withAlpha(50),
        end: Colors.black.withAlpha(20),
      ),
    ),
    // TweenSequenceItem(
    //   weight: 1.0,
    //   tween: ColorTween(
    //     begin: Colors.blue,
    //     end: Colors.pink,
    //   ),
    // ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      // decoration: BoxDecoration(
      // borderRadius: new BorderRadius.circular(5),
      // color: Color(0xFF9A1120),
      // color: Colors.transparent),
      width: 150,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(5),
              color: background.evaluate(
                AlwaysStoppedAnimation(_controller.value),
              ),
            ),
          );
        },
      ),
    );
  }
}
