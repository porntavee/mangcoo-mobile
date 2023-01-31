import 'package:flutter/material.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';

// ignore: must_be_immutable
class ListContentKnowledgeHorizontal extends StatefulWidget {
  ListContentKnowledgeHorizontal(
      {Key key,
      this.title,
      this.url,
      this.model,
      this.urlComment,
      this.navigationList,
      this.navigationForm})
      : super(key: key);

  final String title;
  final String url;
  final Future<dynamic> model;
  final String urlComment;
  final Function() navigationList;
  final Function(String, String, dynamic, String) navigationForm;

  @override
  _ListContentKnowledgeHorizontal createState() =>
      _ListContentKnowledgeHorizontal();
}

class _ListContentKnowledgeHorizontal
    extends State<ListContentKnowledgeHorizontal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          height: 210,
          color: Colors.transparent,
          child: renderCard(widget.title, widget.url, widget.model,
              widget.urlComment, widget.navigationForm),
        ),
      ],
    );
  }
}

renderCard(String title, String url, Future<dynamic> model, String urlComment,
    Function navigationForm) {
  return FutureBuilder<dynamic>(
    future: model, // function where you call your api
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      // AsyncSnapshot<Your object type>

      if (snapshot.hasData) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            return myCard(title, index, snapshot.data.length, url,
                snapshot.data[index], urlComment, context, navigationForm);
          },
        );
        // } else if (snapshot.hasError) {
        //   return Center(child: Text('Error: ${snapshot.error}'));
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

myCard(String title, int index, int lastIndex, String url, dynamic model,
    String urlComment, BuildContext context, Function navigationForm) {
  return InkWell(
    onTap: () {
      navigationForm(model['code'], url, model, urlComment);
    },
    child: Container(
      margin: index == 0
          ? EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 5.0)
          : index == lastIndex - 1
              ? EdgeInsets.only(left: 5.0, bottom: 5.0, top: 5.0, right: 10.0)
              : EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          // color: Color(0xFF000070),
          color: Colors.transparent),
      width: 150,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.transparent,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(model['imageUrl']),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 160),
            padding: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.topCenter,
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  model['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: 'Kanit',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
