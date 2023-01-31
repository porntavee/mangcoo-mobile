import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

header(BuildContext context, Function functionGoBack,
    {String title = '',
    bool isButtonRight = false,
    Function rightButton,
    String menu = ''}) {
  return AppBar(
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    elevation: 0.0,
    titleSpacing: 5,
    automaticallyImplyLeading: false,
    title: Text(
      title != null ? title : '',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
      ),
    ),
    leading: InkWell(
      onTap: () => functionGoBack(),
      child: Container(
        child: Image.asset(
          "assets/images/arrow_left.png",
          color: Colors.white,
          width: 40,
          height: 40,
        ),
      ),
    ),
    actions: <Widget>[
      isButtonRight == true
          ? menu == 'notification'
              ? Container(
                  child: Container(
                    child: Container(
                      width: 42.0,
                      height: 42.0,
                      margin:
                          EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => rightButton(),
                        child: Image.asset('assets/images/task_list.png'),
                      ),
                    ),
                  ),
                )
              : Container(
                  child: Container(
                    child: Container(
                      width: 42.0,
                      height: 42.0,
                      margin:
                          EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => rightButton(),
                        child: Image.asset('assets/images/reverse_time.png'),
                      ),
                    ),
                  ),
                )
          : Container(),
    ],
  );
}
