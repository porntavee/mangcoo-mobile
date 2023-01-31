import 'package:flutter/material.dart';

class InkWellUnfocus extends StatefulWidget {
  const InkWellUnfocus({Key key, @required this.child}) : super(key: key);

  final Widget child;

  @override
  _InkWellUnfocusState createState() => _InkWellUnfocusState();
}

class _InkWellUnfocusState extends State<InkWellUnfocus> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: widget.child,
    );
  }
}
