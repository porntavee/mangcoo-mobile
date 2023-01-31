import 'package:wereward/component/loading_image_network.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/sso/list_content_horizontal_loading.dart';
import 'package:wereward/shared/extension.dart';

// ignore: must_be_immutable
class ListContentHorizontal extends StatefulWidget {
  ListContentHorizontal({
    Key key,
    this.title,
    this.imageUrl,
    this.url,
    this.model,
    this.urlComment,
    this.navigationList,
    this.navigationForm,
    this.urlGallery,
  }) : super(key: key);

  final String title;
  final String imageUrl;
  final String url;
  final String urlGallery;
  final Future<dynamic> model;
  final String urlComment;
  final Function() navigationList;
  final Function(String, String, dynamic, String, String) navigationForm;

  @override
  _ListContentHorizontal createState() => _ListContentHorizontal();
}

class _ListContentHorizontal extends State<ListContentHorizontal> {
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(left: 15, right: 5.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFC5DAFC),
                        Color(0xFF000070),
                      ],
                      begin: Alignment.topLeft,
                      end: new Alignment(1, 0.0),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 40,
                  width: 40,
                  child: Container(
                    child: loadingImageNetwork(
                      widget.imageUrl,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
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
              ],
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
          height: 170,
          child: renderCard(
            widget.title,
            widget.url,
            widget.model,
            widget.urlComment,
            widget.navigationForm,
            widget.urlGallery,
          ),
        ),
      ],
    );
  }
}

renderCard(
  String title,
  String url,
  Future<dynamic> model,
  String urlComment,
  Function navigationForm,
  String urlGallery,
) {
  return FutureBuilder<dynamic>(
    future: model, // function where you call your api
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      // AsyncSnapshot<Your object type>

      if (snapshot.hasData) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            return myCard(
              title,
              index,
              snapshot.data.length,
              url,
              snapshot.data[index],
              urlComment,
              context,
              navigationForm,
              urlGallery,
            );
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

myCard(
  String title,
  int index,
  int lastIndex,
  String url,
  dynamic model,
  String urlComment,
  BuildContext context,
  Function navigationForm,
  String urlGallery,
) {
  return InkWell(
    onTap: () {
      navigationForm(model['code'], url, model, urlComment, urlGallery);
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
            height: 100,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(5.0),
                topRight: const Radius.circular(5.0),
              ),
              color: Colors.white.withAlpha(220),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(model['imageUrl']),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 100),
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.only(
                  bottomLeft: const Radius.circular(5.0),
                  bottomRight: const Radius.circular(5.0),
                ),
                color: Colors.black.withAlpha(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: 'Kanit',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  dateStringToDate(model['createDate']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                    fontFamily: 'Kanit',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
