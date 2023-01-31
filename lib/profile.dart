import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/pages/blank_page/blank_loading.dart';

class Profile extends StatefulWidget {
  Profile({Key key, this.model, this.organizationImage, this.nav, this.nav1})
      : super(key: key);

  final Future<dynamic> model;
  final Future<dynamic> organizationImage;
  final Function nav;
  final Function nav1;

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  final storage = new FlutterSecureStorage();

  String _profileCode;

  @override
  void initState() {
    _callInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _buildCard(model: snapshot.data);
        } else if (snapshot.hasError) {
          return _buildCard(model: {
            'imageUrl': '',
            'firstName': 'การเชื่อมต่อขัดข้อง',
            'lastName': ''
          });
        } else {
          return Container(
            height: 50,
          );
          // return _buildCard(
          //     model: {'imageUrl': '', 'firstName': '', 'lastName': ''});
        }
      },
    );
  }

  _buildCard({dynamic model}) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.amber,
        // border: Border.all(color: Colors.white),
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF7900),
            Color(0xFFFF7900),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.all('${model['imageUrl']}' != '' ? 0.0 : 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 9 / 100),
                    color: Color(0xFFFF7900),
                  ),
                  height: width * 18 / 100,
                  width: width * 18 / 100,
                  child: GestureDetector(
                    onTap: () => widget.nav(),
                    child: model['imageUrl'] != '' && model['imageUrl'] != null
                        ? CircleAvatar(
                            backgroundColor: Colors.black,
                            backgroundImage: model['imageUrl'] != null
                                ? NetworkImage(model['imageUrl'])
                                : null,
                          )
                        : Container(
                            padding: EdgeInsets.all(10.0),
                            child: Image.asset(
                              'assets/images/user_not_found.png',
                              color: Theme.of(context).primaryColorLight,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.nav(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Container(
                        //   padding: EdgeInsets.only(
                        //     left: 375 * 3 / 100,
                        //     right: 375 * 1 / 100,
                        //   ),
                        //   child: Text(
                        //     'อาสากู้ภัย',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 18.0,
                        //       fontWeight: FontWeight.bold,
                        //       fontFamily: 'Kanit',
                        //     ),
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 5.0,
                          ),
                          child: Text(
                            '${model['firstName']} ${model['lastName']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Kanit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 10.0,
                          ),
                          child: _buildOrganizationImage(),
                        ),

                        //   widget.imageLv0.length > 0
                        //       ? Row(
                        //           children: [
                        //             Container(
                        //               margin: EdgeInsets.only(right: 10),
                        //               child: Text(
                        //                 'สมาชิก : ',
                        //                 style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontSize: 10,
                        //                   fontWeight: FontWeight.normal,
                        //                   fontFamily: 'Kanit',
                        //                 ),
                        //               ),
                        //             ),
                        //             Row(
                        //               children: widget.imageLv0
                        //                   .map<Widget>(
                        //                     (e) => Container(
                        //                       margin:
                        //                           EdgeInsets.only(right: 5.0),
                        //                       decoration: BoxDecoration(
                        //                         color: Colors.transparent,
                        //                       ),
                        //                       height: 25,
                        //                       width: 25,
                        //                       child: e != null
                        //                           ? Image.network(e)
                        //                           : Container(),
                        //                     ),
                        //                   )
                        //                   .toList(),
                        //             )
                        //           ],
                        //         )
                        //       : Text(
                        //           model['status'] == 'A'
                        //               ? model['officerCode'] != null
                        //                   ? 'สมาชิก : '
                        //                   : 'สมาชิก : '
                        //               : model['status'] == 'N'
                        //                   ? 'สมาชิก : ท่านยังไม่ได้ยืนยันตน กรุณายืนยันตัวตน'
                        //                   : 'สมาชิก : ยืนยันตัวตนแล้ว รอเจ้าหน้าที่ตรวจสอบข้อมูล',
                        //           style: TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 10,
                        //             fontWeight: FontWeight.normal,
                        //             fontFamily: 'Kanit',
                        //           ),
                        //           maxLines: 2,
                        //           overflow: TextOverflow.ellipsis,
                        //         ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              // height: 50,
              // width: width * 8 / 100,
              child: InkWell(
                onTap: () => widget.nav1(),
                child: Image.asset(
                  'assets/images/letter.png',
                  height: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildOrganizationImage() {
    return FutureBuilder<dynamic>(
      future: widget.organizationImage, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        // data from refresh api
        if (snapshot.hasData) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'สมาชิก : ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Kanit',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                height: 30,
                // padding: EdgeInsets.only(top: 5),
                child: ListView.builder(
                  shrinkWrap: true, // 1st add
                  physics: ClampingScrollPhysics(), // 2nd
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return snapshot.data[0]['imageUrl'] != ''
                        ? CircleAvatar(
                            child: ClipOval(
                              child: Image.network(
                                snapshot.data[index]['imageUrl'],
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              snapshot.data[0]['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                  },
                ),
              )
            ],
          );
        } else if (snapshot.hasError) {
          // goLogin();
          return BlankLoading();
        } else {
          return BlankLoading();
        }
      },
    );
  }

  _callInit() async {
    var profileCode = await storage.read(key: 'profileCode10');
    if (profileCode != '' && profileCode != null)
      setState(() {
        _profileCode = profileCode;
      });
  }
}
