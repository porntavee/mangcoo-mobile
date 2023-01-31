import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:toast/toast.dart';

class SSOOnlineServiceHorizontal extends StatefulWidget {
  SSOOnlineServiceHorizontal({Key key, this.title, this.model})
      : super(key: key);

  final String title;
  final dynamic model;

  @override
  _SSOOnlineServiceHorizontal createState() => _SSOOnlineServiceHorizontal();
}

class _SSOOnlineServiceHorizontal extends State<SSOOnlineServiceHorizontal> {
  Future<dynamic> _futureModel;
  Function nav;

  @override
  void initState() {
    super.initState();
    _futureModel = post(
      '${menuApi}read',
      {'skip': 0, 'limit': 100},
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    // [
                    //   myCircle(
                    //       snapshot.data[1]['title'],
                    //       '(ว่างงานหรือชราภาพ)',
                    //       snapshot.data[1]['imageUrl'],
                    //       () => {
                    //             Toast.show(
                    //               snapshot.data[1]['title'],
                    //               context,
                    //               duration: Toast.LENGTH_SHORT,
                    //               gravity: Toast.BOTTOM,
                    //             )
                    //           }),
                    //   myCircle(
                    //       snapshot.data[2]['title'],
                    //       '',
                    //       snapshot.data[2]['imageUrl'],
                    //       () => {
                    //             Toast.show(
                    //               snapshot.data[2]['title'],
                    //               context,
                    //               duration: Toast.LENGTH_SHORT,
                    //               gravity: Toast.BOTTOM,
                    //             )
                    //           }),
                    //   myCircle(
                    //       snapshot.data[3]['title'],
                    //       '',
                    //       snapshot.data[3]['imageUrl'],
                    //       () => {
                    //             Toast.show(
                    //               snapshot.data[3]['title'],
                    //               context,
                    //               duration: Toast.LENGTH_SHORT,
                    //               gravity: Toast.BOTTOM,
                    //             )
                    //           }),
                    //   myCircle(
                    //       snapshot.data[4]['title'],
                    //       '',
                    //       snapshot.data[4]['imageUrl'],
                    //       () => {
                    //             Toast.show(
                    //               snapshot.data[4]['title'],
                    //               context,
                    //               duration: Toast.LENGTH_SHORT,
                    //               gravity: Toast.BOTTOM,
                    //             )
                    //           }),
                    // ],

                    [
                  myCircle(
                      'ขอรับเงินทดแทน',
                      '(ว่างงานหรือชราภาพ)',
                      'assets/images/e-service-1.png',
                      () => {
                            Toast.show(
                              snapshot.data[4]['title'],
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM,
                            )
                          }),
                  myCircle(
                      'เปลี่ยนโรงพยาบาล',
                      '',
                      'assets/images/e-service-2.png',
                      () => {
                            Toast.show(
                              snapshot.data[4]['title'],
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM,
                            )
                          }),
                  myCircle(
                      'การเบิกสิทธิประโยชน์',
                      '',
                      'assets/images/e-service-3.png',
                      () => {
                            Toast.show(
                              snapshot.data[4]['title'],
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM,
                            )
                          }),
                  myCircle(
                      'สมัครเป็นผู้ประกันตน',
                      '',
                      'assets/images/e-service-4.png',
                      () => {
                            Toast.show(
                              snapshot.data[4]['title'],
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM,
                            )
                          }),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  myCircle(
                    '',
                    '(ว่างงานหรือชราภาพ)',
                    '',
                    () => {
                      Toast.show(
                        '',
                        context,
                        duration: Toast.LENGTH_SHORT,
                        gravity: Toast.BOTTOM,
                      )
                    },
                  ),
                  myCircle(
                    '',
                    '',
                    '',
                    () => {
                      Toast.show(
                        '',
                        context,
                        duration: Toast.LENGTH_SHORT,
                        gravity: Toast.BOTTOM,
                      )
                    },
                  ),
                  myCircle(
                    '',
                    '',
                    '',
                    () => {
                      Toast.show(
                        '',
                        context,
                        duration: Toast.LENGTH_SHORT,
                        gravity: Toast.BOTTOM,
                      )
                    },
                  ),
                  myCircle(
                    '',
                    '',
                    '',
                    () => {
                      Toast.show(
                        '',
                        context,
                        duration: Toast.LENGTH_SHORT,
                        gravity: Toast.BOTTOM,
                      )
                    },
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

myCircle(String title, String subTitle, String image, Function nav) {
  return InkWell(
      onTap: () {
        nav();
      },
      child: Container(
        height: 110.0,
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFFC324),
              radius: 30,
              child: Image.asset(
                image,
                width: 35,
                height: 35,
              ),
            ),
            Container(
              width: 75.0,
              margin: EdgeInsets.only(top: 5.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000070),
                  fontFamily: 'Kanit',
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              child: Text(
                subTitle,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000070),
                  fontFamily: 'Kanit',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ));
}
