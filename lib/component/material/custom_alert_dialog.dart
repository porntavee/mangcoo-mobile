// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class Dialog extends StatelessWidget {
  const Dialog({
    Key key,
    this.child,
    this.color,
    this.mxHeight: 165,
    this.mnWidth: 165,
    this.alignment: Alignment.topRight,
    this.insetAnimationDuration: const Duration(milliseconds: 100),
    this.insetAnimationCurve: Curves.decelerate,
  }) : super(key: key);

  final Widget child;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final double mxHeight;
  final double mnWidth;
  final Alignment alignment;
  final Color color;

  Color _getColor(BuildContext context) {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 35.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: new MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: new Align(
          alignment: alignment,
          child: new AnimatedContainer(
            duration: Duration(milliseconds: 100),
            constraints: BoxConstraints(minWidth: mnWidth, maxHeight: mxHeight),
            child: new Material(
              borderRadius: BorderRadius.circular(5),
              elevation: 10.0,
              color: color != null ? color : _getColor(context),
              type: MaterialType.card,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// See also:
///
///  * [SimpleDialog], which handles the scrolling of the contents but has no [actions].
///  * [Dialog], on which [AlertDialog] and [SimpleDialog] are based.
///  * [showDialog], which actually displays the dialog and returns its result.
///  * <https://material.google.com/components/dialogs.html#dialogs-alerts>
class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    Key key,
    this.content,
    this.width: 180,
    this.height: 160,
    this.color,
    this.alignment: Alignment.topRight,
    this.contentPadding: const EdgeInsets.all(0),
    this.semanticLabel,
  })  : assert(contentPadding != null),
        super(key: key);

  final Widget content;
  final double width;
  final double height;
  final Alignment alignment;
  final EdgeInsetsGeometry contentPadding;
  final String semanticLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    String label = semanticLabel;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        label = semanticLabel;
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        label = semanticLabel ??
            MaterialLocalizations.of(context)?.alertDialogLabel;
    }

    if (content != null) {
      children.add(new Flexible(
        child: new Padding(
          padding: contentPadding,
          child: new DefaultTextStyle(
            style: Theme.of(context).textTheme.subtitle1,
            child: content,
          ),
        ),
      ));
    }

    Widget dialogChild = new IntrinsicWidth(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    if (label != null)
      dialogChild =
          new Semantics(namesRoute: true, label: label, child: dialogChild);

    return new Dialog(
      child: dialogChild,
      mxHeight: height,
      mnWidth: width,
      color: color,
      alignment: alignment,
    );
  }
}

class Dialog1 extends StatelessWidget {
  const Dialog1({
    Key key,
    this.child,
    this.insetAnimationDuration: const Duration(milliseconds: 100),
    this.insetAnimationCurve: Curves.decelerate,
  }) : super(key: key);
  final Widget child;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;

  Color _getColor(BuildContext context) {
    return Theme.of(context).dialogBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: new MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: new Center(
          child: new ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280.0),
            child: new Material(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              elevation: 30.0,
              color: _getColor(context),
              type: MaterialType.card,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAlertDialog1 extends StatelessWidget {
  const CustomAlertDialog1({
    Key key,
    this.title,
    this.titlePadding,
    this.content,
    this.contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.actions,
    this.semanticLabel,
  })  : assert(contentPadding != null),
        super(key: key);
  final Widget title;
  final EdgeInsetsGeometry titlePadding;
  final Widget content;
  final EdgeInsetsGeometry contentPadding;
  final List<Widget> actions;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    String label = semanticLabel;

    if (title != null) {
      children.add(new Padding(
        padding: titlePadding ??
            new EdgeInsets.fromLTRB(
                24.0, 24.0, 24.0, content == null ? 20.0 : 0.0),
        child: new DefaultTextStyle(
          style: Theme.of(context).textTheme.subtitle1,
          child: new Semantics(child: title, namesRoute: true),
        ),
      ));
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          label = semanticLabel;
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          label = semanticLabel ??
              MaterialLocalizations.of(context)?.alertDialogLabel;
      }
    }

    if (content != null) {
      children.add(new Flexible(
        child: new Padding(
          padding: contentPadding,
          child: new DefaultTextStyle(
            style: Theme.of(context).textTheme.headline1,
            child: content,
          ),
        ),
      ));
    }

    if (actions != null) {
      children.add(new ButtonTheme.fromButtonThemeData(
        child: new ButtonBar(
          children: actions,
        ),
      ));
    }

    Widget dialogChild = new IntrinsicWidth(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    if (label != null)
      dialogChild =
          new Semantics(namesRoute: true, label: label, child: dialogChild);

    return new Dialog1(child: dialogChild);
  }
}

class Dialog2 extends StatelessWidget {
  const Dialog2({
    Key key,
    this.child,
    this.insetAnimationDuration: const Duration(milliseconds: 100),
    this.insetAnimationCurve: Curves.decelerate,
  }) : super(key: key);
  final Widget child;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;

  Color _getColor(BuildContext context) {
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: new MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: new Center(
          child: new ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280.0),
            child: new Material(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              elevation: 30.0,
              color: _getColor(context),
              type: MaterialType.card,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAlertDialog2 extends StatelessWidget {
  const CustomAlertDialog2({
    Key key,
    this.title,
    this.titlePadding,
    this.content,
    this.contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.actions,
    this.semanticLabel,
  })  : assert(contentPadding != null),
        super(key: key);
  final Widget title;
  final EdgeInsetsGeometry titlePadding;
  final Widget content;
  final EdgeInsetsGeometry contentPadding;
  final List<Widget> actions;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    String label = semanticLabel;

    if (title != null) {
      children.add(new Padding(
        padding: titlePadding ??
            new EdgeInsets.fromLTRB(
                24.0, 24.0, 24.0, content == null ? 20.0 : 0.0),
        child: new DefaultTextStyle(
          style: Theme.of(context).textTheme.subtitle1,
          child: new Semantics(child: title, namesRoute: true),
        ),
      ));
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          label = semanticLabel;
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          label = semanticLabel ??
              MaterialLocalizations.of(context)?.alertDialogLabel;
      }
    }

    if (content != null) {
      children.add(new Flexible(
        child: new Padding(
          padding: contentPadding,
          child: new DefaultTextStyle(
            style: Theme.of(context).textTheme.headline1,
            child: content,
          ),
        ),
      ));
    }

    if (actions != null) {
      children.add(new ButtonTheme.fromButtonThemeData(
        child: new ButtonBar(
          children: actions,
        ),
      ));
    }

    Widget dialogChild = new IntrinsicWidth(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    if (label != null)
      dialogChild =
          new Semantics(namesRoute: true, label: label, child: dialogChild);

    return new Dialog2(child: dialogChild);
  }
}
