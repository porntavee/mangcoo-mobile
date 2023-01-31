import 'dart:convert';
import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';

import 'help_center_form.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final storage = new FlutterSecureStorage();

  Future<dynamic> futureModel;

  ScrollController scrollController = new ScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _callread();
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _callread() {
    futureModel = postDio('${server}m/helpCenter/read', {});
  }

  _header(column) {
    column.add(SizedBox(height: 15));
    column.add(
      Text(
        'ศูนย์ช่วยเหลือ',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    column.add(SizedBox(height: 15));
    column.add(
      Padding(
        padding: EdgeInsets.all(5),
        child: _buildText('คำถามยอดฮิต', 18.00, Color(0xFF000000)),
      ),
    );
    column.add(_buildLine());
    return column;
  }

  _detail(column, model) {
    for (var i = 0; i < model.length; i++) {
      column.add(SizedBox(height: 10));
      column.add(
        Padding(
            padding: EdgeInsets.all(5),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelpCenterForm(
                    model: model[i],
                  ),
                ),
              ),
              child: _buildText(model[i]['title'], 16.00, Color(0xFF707070)),
            )),
      );
      column.add(_buildLine());
    }
    return column;
  }

  contentCard(model) {
    var column = List<Widget>();
    column = _header(column);
    column = _detail(column, model);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: column,
    );
  }

  _buildText(String title, double size, Color color) {
    return Text(
      title,
      style: new TextStyle(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
      ),
    );
  }

  _buildLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E2E2),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        appBar: header2(
          context,
          title: 'ศูนย์ช่วยเหลือ',
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            left: 15.0,
                            right: 15.0,
                          ),
                          child: contentCard(snapshot.data),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError)
              return Center(
                child: Container(
                  color: Colors.white,
                  child: dialogFail(context),
                ),
              );
            else
              return Container();
          },
        ),
      ),
    );
  }
}
