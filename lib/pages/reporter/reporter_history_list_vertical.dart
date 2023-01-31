import 'package:flutter/material.dart';
import 'package:wereward/pages/reporter/reporter_history_form.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter/rendering.dart';

class ReporterHistoryListVertical extends StatefulWidget {
  ReporterHistoryListVertical({
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
  _ReporterHistoryListVertical createState() => _ReporterHistoryListVertical();
}

class _ReporterHistoryListVertical extends State<ReporterHistoryListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  checkImageAvatar(String img) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: img != null
          ? NetworkImage(
              img,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              alignment: Alignment.center,
              height: 200,
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
              color: Colors.transparent,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReporterHistortForm(
                            url: widget.url,
                            code: snapshot.data[index]['code'],
                            model: snapshot.data[index],
                            urlComment: widget.urlComment,
                            urlGallery: widget.urlGallery,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(bottom: 2.0, top: 5.0),
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFFFFFFFF),
                        ),
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // height: 20,
                              child: Text(
                                // '${snapshot.data[index]['categoryList'][0]['title']}',
                                '${snapshot.data[index]['title']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                // height: 50,
                                child: Text(
                                  //  ${snapshot.data[index]['lv1']} ${snapshot.data[index]['lv2']} ${snapshot.data[index]['lv3']} ${snapshot.data[index]['lv4']}
                                  'สังกัด: ${snapshot.data[index]['lv0']}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Color(snapshot.data[index]['color']),
                                  size: 14,
                                ),
                                _widgetTextTitileStatus(
                                    status: ' สถานนะ',
                                    color: snapshot.data[index]['color']),
                                _widgetTextTitileStatus(
                                    status:
                                        ' ${snapshot.data[index]['status']}',
                                    color: snapshot.data[index]['color']),
                              ],
                            ),
                            Container(
                              // height: 50,
                              child: Text(
                                'ผู้แจ้ง: ${snapshot.data[index]['firstName']} ${snapshot.data[index]['lastName']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                'วันที่ ' +
                                    dateStringToDate(
                                        snapshot.data[index]['createDate']),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        } else {
          return Container();
        }
      },
    );
  }

  _widgetTextTitileStatus({String status, int color}) {
    return Text(
      status,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 13, color: Color(color)),
    );
  }
}
