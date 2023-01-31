import 'package:wereward/component/loading_image_network.dart';
import 'package:flutter/material.dart';
import 'package:wereward/pages/blank_page/blank_data.dart';
import 'package:wereward/pages/event_calendar/event_calendar_form.dart';

class EventCalendarListVertical extends StatefulWidget {
  EventCalendarListVertical({
    Key key,
    this.site,
    this.model,
    this.title,
    this.url,
    this.urlComment,
    this.urlGallery,
  }) : super(key: key);

  final String site;
  final Future<dynamic> model;
  final String title;
  final String url;
  final String urlComment;
  final String urlGallery;

  @override
  _EventCalendarListVertical createState() => _EventCalendarListVertical();
}

class _EventCalendarListVertical extends State<EventCalendarListVertical> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kanit',
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                ),
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  // return Container(height: 300.0,color: Colors.red,margin: EdgeInsets.all(5.0),);
                  return myCard(index, snapshot.data.length,
                      snapshot.data[index], context);
                  // return demoItem(snapshot.data[index]);
                },
              ),
            );
          }
        } else {
          return blankGridData(context);
        }
      },
    );
  }

  demoItem(dynamic model) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventCalendarForm(
                    urlGallery: widget.urlGallery,
                    urlComment: widget.urlComment,
                    model: model,
                    url: widget.url,
                    code: model['code'],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: new BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: new BorderRadius.circular(6.0),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: loadingImageNetwork(
                    model['imageUrl'],
                  )
                  //               Image.network(
                  //   model['imageUrl'],
                  // ),
                  ),
            ),
          ),
        ),
        Container(
          child: Center(
            child: Image.asset('assets/images/bar.png'),
          ),
        ),
      ],
    );
  }

  myCard(int index, int lastIndex, dynamic model, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventCalendarForm(
              urlGallery: widget.urlGallery,
              urlComment: widget.urlComment,
              model: model,
              url: widget.url,
              code: model['code'],
            ),
          ),
        );
      },
      child: Container(
        margin: index % 2 == 0
            ? EdgeInsets.only(bottom: 5.0, right: 5.0)
            : EdgeInsets.only(bottom: 5.0, left: 5.0),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Color(0xFFFF7900),
        ),
        child: Column(
          // alignment: Alignment.topCenter,
          children: [
            Expanded(
              child: Container(
                height: 157.0,
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
            ),
            Container(
              // margin: EdgeInsets.only(top: 157.0),
              padding: EdgeInsets.all(5),
              alignment: Alignment.topLeft,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.only(
                  bottomLeft: const Radius.circular(5.0),
                  bottomRight: const Radius.circular(5.0),
                ),
                color: Colors.black.withAlpha(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Color(0xFFFFFFFF),
                      // color: Colors.white,
                      fontFamily: 'Kanit',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  // Text(
                  //   dateStringToDate(model['createDate']),
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.normal,
                  //     fontSize: 8,
                  //     fontFamily: 'Kanit',
                  //     color: Colors.white,
                  //   ),
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
