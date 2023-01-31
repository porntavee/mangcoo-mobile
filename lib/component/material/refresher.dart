import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefresherCT extends StatefulWidget {
  RefresherCT({
    Key key,
    @required this.child,
    this.onRefresh,
    this.onLoading,
    this.controller,
  }) : super(key: key);

  final Widget child;
  final Function onRefresh;
  final Function onLoading;
  final RefreshController controller;

  @override
  _RefresherCT createState() => _RefresherCT();
}

class _RefresherCT extends State<RefresherCT> with WidgetsBindingObserver {
  // use this in your page.
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(
        complete: Container(
          child: Text(''),
        ),
        completeDuration: Duration(milliseconds: 0),
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: widget.controller,
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoading,
      child: widget.child,
    );
  }
}
