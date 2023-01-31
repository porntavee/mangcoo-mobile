import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ListNewPrivilegePage extends StatefulWidget {
  ListNewPrivilegePage({
    Key key,
    this.title,
    this.model,
    this.navigationList,
    this.rightButton,
    this.navigationForm,
  }) : super(key: key);

  final String title;
  final Widget rightButton;
  final Future<dynamic> model;
  final Function() navigationList;
  final Function(dynamic) navigationForm;

  @override
  _ListNewPrivilegePage createState() => _ListNewPrivilegePage();
}

class _ListNewPrivilegePage extends State<ListNewPrivilegePage> {
  ScrollController scrollController;
  double _scrollPosition;
  double maxWidth = 0.0;

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _scrollListener() {
    setState(() {
      _scrollPosition = scrollController.position.pixels;

      maxWidth = scrollController.position.maxScrollExtent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      width: double.infinity,
      color: Color(0xFF9CE0F6),
      // color: Colors.red,
      height: 130,
      child: Column(
        children: [
          SizedBox(height: 5),
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
                    color: themeChange.darkTheme
                        ? Colors.white
                        : Theme.of(context).primaryColor,
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
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 90,
            child: renderCard(),
          ),
        ],
      ),
    );
  }

  renderCard() {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return
              // Scrollbar(
              //   isAlwaysShown: true,
              //   controller: scrollController,
              //   thickness: 5.0,
              //   radius: Radius.circular(5),
              //   child:
              ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return myCard(
                model: snapshot.data[index],
                index: index,
                lastIndex: snapshot.data.length,
              );
            },
            // ),
          );
        } else {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListContentHorizontalLoading();
            },
          );
        }
      },
    );
  }

  myCard({dynamic model, int index = 0, int lastIndex = 0}) {
    EdgeInsets margin = EdgeInsets.only(right: 10.0);

    return InkWell(
      onTap: () {
        widget.navigationForm(model);
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: Colors.transparent,
        ),
        width: 90,
        height: 90,
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: loadingImageNetwork(
            model['imageUrl'],
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
