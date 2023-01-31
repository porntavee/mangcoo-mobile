import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';

// ignore: must_be_immutable
class ListContentVertical extends StatefulWidget {
  ListContentVertical({Key key, this.title, this.url}) : super(key: key);

  final String title;
  final String url;
  // Future<dynamic> _model;
  // String _urlComment;

  @override
  _ListContentVertical createState() => _ListContentVertical();
}

class _ListContentVertical extends State<ListContentVertical> {
  Future<dynamic> _futureModel;

  @override
  void initState() {
    super.initState();
    _futureModel = post('${widget.url}read', {'skip': 0, 'limit': 10});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(

        // future: widget.model,
        future: _futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true, // 1st add
              physics: ClampingScrollPhysics(), // 2nd
              // scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return myCard('', '', snapshot.data[index], context);
              },
            );
          } else {
            return Text('x');
          }
        });
  }
}

myCard(String title, String url, dynamic model, BuildContext context) {
  return InkWell(
    onTap: () {},
    child: Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          // color: Color(0xFF000070),
          color: Colors.transparent),
      width: 150,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 250,
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
            margin: EdgeInsets.only(top: 250),
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            height: 50,
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
                    color: Colors.white,
                    fontFamily: 'Kanit',
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
