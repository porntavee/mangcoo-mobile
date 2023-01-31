import 'dart:convert';
import 'dart:io';
import 'package:wereward/component/loading_image_network.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wereward/pages/welfare/welfare_form.dart';
import 'package:wereward/shared/extension.dart';

class WelfareListVertical extends StatefulWidget {
  WelfareListVertical({
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
  _WelfareListVertical createState() => _WelfareListVertical();
}

class _WelfareListVertical extends State<WelfareListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
              alignment: Alignment.center,
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
                          builder: (context) => WelfareForm(
                            url: widget.url,
                            code: snapshot.data[index]['code'],
                            model: snapshot.data[index],
                            urlComment: widget.urlComment,
                            urlGallery: widget.urlGallery,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                // color: Color.fromRGBO(0, 0, 2, 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(bottom: 5.0),
                              height: 100,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius:
                                          new BorderRadius.circular(5.0),
                                    ),
                                    padding: EdgeInsets.all(5),
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // margin: EdgeInsets.all(5),
                                              height: 90,
                                              width: 90,
                                              child: Container(
                                                  child: loadingImageNetwork(
                                                '${snapshot.data[index]['imageUrl']}',
                                                fit: BoxFit.cover,
                                              )
                                                  // Image.network(
                                                  //   '${snapshot.data[index]['imageUrl']}',
                                                  //   fit: BoxFit.cover,
                                                  // ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              // color: Colors.red,
                                              width: width * 60 / 100,
                                              margin: EdgeInsets.fromLTRB(
                                                  8, 0, 0, 0),
                                              child: Text(
                                                '${snapshot.data[index]['title']}',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Kanit',
                                                  fontSize: 15,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  8, 0, 0, 0),
                                              child: Text(
                                                dateStringToDate(snapshot
                                                    .data[index]['createDate']),
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Kanit',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Future<dynamic> downloadData() async {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 10 // integer value type
    });
    var response = await http.post(Uri.parse(''), body: body, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    });

    var data = json.decode(response.body);

    // int randomNumber = random.nextInt(10);
    // sleep(Duration(seconds: widget.sleep));
    return Future.value(data['objectData']);
    // return Future.value(response); // return your response
  }

  Future<dynamic> postData() async {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 2 // integer value type
    });

    var client = new http.Client();
    client.post(
        Uri.parse('http://hwpolice.we-builds.com/hwpolice-api/privilege/read'),
        body: body,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        }).then((response) {
      client.close();
      var data = json.decode(response.body);

      if (data.length > 0) {
        sleep(const Duration(seconds: 10));
        setState(() {
          return Future.value(data['objectData']);
        });
      } else {}
    }).catchError((onError) {
      client.close();
    });
  }
}
