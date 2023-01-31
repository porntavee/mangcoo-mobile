import 'package:flutter/material.dart';

class AnimateLoading extends StatefulWidget {
  AnimateLoading({Key key, this.height: 90}) : super(key: key);

  final double height;

  @override
  _AnimateLoading createState() => _AnimateLoading();
}

class _AnimateLoading extends State<AnimateLoading>
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
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            height: widget.height,
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
