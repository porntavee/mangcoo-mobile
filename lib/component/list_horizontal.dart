import 'dart:math';

import 'package:flutter/material.dart';

class ListHorizontal extends StatefulWidget {
  ListHorizontal({Key key, this.site, this.model}) : super(key: key);

  final String site;
  final Future<dynamic> model;

  @override
  _ListHorizontal createState() => _ListHorizontal();
}

class _ListHorizontal extends State<ListHorizontal> {
  Random random = new Random();

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

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
          return Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => PrivilegeForm(
                    //             code: snapshot.data[index]['code'],
                    //           )),
                    // );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: EdgeInsets.all(8),
                        height: 180,
                        width: 180,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(5.0),
                                  topRight: const Radius.circular(5.0),
                                ),
                                color: Color(0xFF000070),
                              ),
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${widget.site}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ),
                            Container(
                              height: 86,
                              width: 86,
                              child: Image.network(
                                '${snapshot.data[index]['imageUrl']}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: new BorderRadius.only(
                                  bottomLeft: const Radius.circular(5.0),
                                  bottomRight: const Radius.circular(5.0),
                                ),
                                color: Color(0xFFE8F0F6),
                              ),
                              padding:
                                  EdgeInsets.only(left: 5, top: 5, bottom: 5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${snapshot.data[index]['title']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 200,
          );
        }
      },
    );
  }
}
