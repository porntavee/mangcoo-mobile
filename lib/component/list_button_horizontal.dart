import 'package:wereward/dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ListButtonHorizontal extends StatefulWidget {
  ListButtonHorizontal(
      {Key key,
      this.title,
      this.imageUrl,
      this.model,
      this.navigationList,
      this.navigationForm,
      this.buttonColor,
      this.textColor,
      this.buttonSize,
      this.imageSize,
      this.maxItem})
      : super(key: key);

  final String title;
  final String imageUrl;
  final Future<dynamic> model;
  final Color buttonColor;
  final Color textColor;
  final double buttonSize;
  final double imageSize;
  final int maxItem;
  final Function navigationList;
  final Function(String) navigationForm;

  @override
  _ListButtonHorizontal createState() => _ListButtonHorizontal();
}

class _ListButtonHorizontal extends State<ListButtonHorizontal> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return FutureBuilder<dynamic>(
        future: widget.model, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: themeChange.darkTheme
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.navigationList();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(right: 15),
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'ดูทั้งหมด',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 13,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return myCircle(
                          title: snapshot.data[index]['title'],
                          image: snapshot.data[index]['imageUrl'],
                          phone: snapshot.data[index]['phone'],
                          backgroundColor: widget.buttonColor,
                          textColor: widget.textColor,
                          buttonSize: widget.buttonSize,
                          imageSize: widget.imageSize,
                          navigationForm: widget.navigationForm);
                    },
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 15),
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: Color(0xFF000070),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.navigationList();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(right: 15),
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'ดูทั้งหมด',
                          style: TextStyle(
                            color: Color(0xFFFFC324),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return myCircle(
                          backgroundColor: Colors.white,
                          textColor: Colors.white,
                          buttonSize: widget.buttonSize,
                          imageSize: widget.imageSize,
                          navigationForm: widget.navigationForm);
                    },
                  ),
                ),
              ],
            );
          }
        });
  }
}

myCircle(
    {String title = '',
    String image = '',
    String phone = '',
    Color backgroundColor,
    Color textColor,
    double buttonSize = 40.0,
    double imageSize = 40.0,
    Function navigationForm}) {
  return Container(
    padding: EdgeInsets.all(5),
    child: Column(
      children: [
        InkWell(
          onTap: () {
            navigationForm(phone);
          },
          child: CircleAvatar(
              backgroundColor: backgroundColor,
              // radius: buttonSize,
              radius: 40,
              backgroundImage: NetworkImage(image)
              // child: image != ''
              //     ? Image.network(
              //         image,
              //         width: imageSize,
              //         height: imageSize,
              //       )
              //     : Container(
              //         width: imageSize,
              //         height: imageSize,
              //       ),
              ),
        ),
        Container(
          width: 85.0,
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Kanit',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
