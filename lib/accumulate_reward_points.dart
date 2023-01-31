import 'package:collection/collection.dart';
import 'package:wereward/login.dart';
import 'package:wereward/profile.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccumulateRewardPointsPage extends StatefulWidget {
  @override
  _AccumulateRewardPointsPageState createState() =>
      _AccumulateRewardPointsPageState();
}

class _AccumulateRewardPointsPageState
    extends State<AccumulateRewardPointsPage> {
  final storage = new FlutterSecureStorage();
  Future<dynamic> _futureProfile;
  Future<dynamic> _futurePoint;
  Future<dynamic> _futurePointCheckIn;
  String imageProfile = '';
  String firstName = '';
  String lastName = '';
  String profileCode = '';
  bool received = false;

  @override
  void initState() {
    _read();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).padding.top + 235),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: _buildHeader(),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: _futurePoint,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: _screen(snapshot.data),
                  // children: [
                  //   _buildHeader(snapshot.data),
                  //   _screen(snapshot.data),
                  // ],
                );
              } else if (snapshot.hasError) {
                return Container();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  _buildHeader() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: FutureBuilder<dynamic>(
            future: _futurePointCheckIn,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final listRow = new List<Widget>();
                int countCheckIn = snapshot.data[0]['countCheckIn'];
                for (var i = 0; i < snapshot.data[0]['numberOfDay']; i++) {
                  listRow.add(SizedBox(
                    width: 20,
                  ));
                  listRow.add(
                    _buildButtonDay(snapshot.data[0]['point'].toString(),
                        'วันนี้ ${i + 1}', countCheckIn > 0 ? true : false),
                  );
                  countCheckIn--;
                }
                // received = snapshot.data[0]['isCheckPoint'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 40,
                          child: Text(
                            'สะสมคะแนน',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 20,
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          padding:
                              EdgeInsets.all(imageProfile != '' ? 0.0 : 5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(45),
                              color: Colors.white70),
                          child: imageProfile != null && imageProfile != ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.black,
                                  backgroundImage:
                                      imageProfile != null && imageProfile != ''
                                          ? NetworkImage(imageProfile)
                                          : null,
                                )
                              : Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    'assets/images/user_not_found.png',
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstName + ' ' + lastName,
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${snapshot.data[0]['sumPoint']} คะแนน',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    profileCode != null && profileCode != ''
                        ? InkWell(
                            onTap: () {
                              snapshot.data[0]['isCheckPoint'] =
                                  !snapshot.data[0]['isCheckPoint'];
                              if (snapshot.data[0]['isCheckPoint']) {
                                postDio(server + 'm/point/create', {
                                  "reference": snapshot.data[0]['code'],
                                  "point": snapshot.data[0]['point'],
                                  'isActive': true
                                });
                                setState(() {
                                  _read();
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInCubic,
                              height: 35,
                              width: 210,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: snapshot.data[0]['isCheckPoint']
                                    ? Color(0xFF505050)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                snapshot.data[0]['isCheckPoint']
                                    ? 'เช็คอินรับคะแนนเรียบร้อย'
                                    : 'เช็คอิน รับ ${snapshot.data[0]['point']} คะแนน',
                                style: TextStyle(
                                  fontFamily: 'Kannit',
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: snapshot.data[0]['isCheckPoint']
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginPage(),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInCubic,
                              height: 35,
                              width: 210,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFFFFFFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  fontFamily: 'Kannit',
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        height: 90,
                        width: double.infinity,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: listRow,
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Container();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  _buildButtonDay(String day, String title, bool status) {
    return InkWell(
      child: Column(
        children: [
          Container(
            height: 25,
            width: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status ? Color(0xFF62E79C) : Colors.white,
            ),
            child: status
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15,
                  )
                : Text(
                    day,
                    style: TextStyle(
                      fontFamily: 'Kannit',
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Kannit',
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  _screen(dynamic data) {
    final listColumn = new List<Widget>();
    var newMap = groupBy(data, (obj) => obj['categoryList'][0]['title'])
        .map((k, v) => MapEntry(
            k,
            v
                .map((item) => {
                      'title': item['categoryList'][0]['title'],
                      'imageUrl': item['categoryList'][0]['imageUrl'],
                      'data': data
                          .where((e) =>
                              e['category'] == item['categoryList'][0]['code'])
                          .toList(),
                    })
                .toList()));

    // listColumn.add(_buildHeader());
    for (var item in newMap.values) {
      listColumn.add(
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 15, left: 15, right: 15),
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Text(
              item[0]['title'],
              style: TextStyle(
                fontFamily: 'Kanit',
                color: Theme.of(context).primaryColor,
                fontSize: 15,
              ),
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.all(15),
              physics: ClampingScrollPhysics(),
              itemCount: item[0]['data'].length,
              itemBuilder: (context, index) {
                return _buildItem(
                    item[0]['data'][index]['imageUrl'],
                    item[0]['data'][index]['title'],
                    item[0]['data'][index]['point'].toString(),
                    item[0]['data'][index]['isCheckPoint']);
              },
            ),
          ],
        ),
      );
    }
    return listColumn;
  }

  _buildItem(String image, String title, String point, bool status) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).accentColor,
            ),
            child: Image.network(
              image,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$point คะแนน',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    color: Theme.of(context).accentColor,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Container(
            height: 25,
            width: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status ? Color(0xFF62E79C) : Color(0xFF808080),
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }

  _read() async {
    imageProfile = await storage.read(key: 'profileImageUrl');
    firstName = await storage.read(key: 'profileFirstName');
    lastName = await storage.read(key: 'profileLastName');

    if (imageProfile == null) imageProfile = '';
    if (firstName == null) firstName = '';
    if (lastName == null) lastName = '';

    //read profile
    profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null)
    setState(() {
      _futureProfile = postDio(profileReadApi, {"code": profileCode});
      _futurePoint = postDio(server + 'm/point/read', {});
      _futurePointCheckIn = postDio(server + 'm/point/readCheckIn', {});
    });
  }
}
