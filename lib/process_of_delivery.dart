import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:wereward/component/launcher_google_maps.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';

const kTileHeight = 50.0;

class ProcessOfDeliveryPage extends StatefulWidget {
  const ProcessOfDeliveryPage({Key key, @required this.model})
      : super(key: key);

  final dynamic model;

  @override
  _ProcessOfDeliveryPageState createState() => _ProcessOfDeliveryPageState();
}

class _ProcessOfDeliveryPageState extends State<ProcessOfDeliveryPage> {
  dynamic model = {};
  dynamic modelT = [];
  @override
  void initState() {
    model = widget.model;
    setmodelT();
    super.initState();
  }

  setmodelT() {
    modelT = [
      {
        'title': 'พัสดุถูกจัดส่งสำเร็จแล้ว',
        'status': 'A',
        'time': '23.49',
        'date': '12 ก.ค.'
      },
      {
        'title': 'พัสดุถูกเข้ารับโดยบริษัทขนส่ง เรียบร้อยแล้ว',
        'status': 'N',
        'time': '03.46',
        'date': '9 ก.ค.'
      },
      {
        'title': 'พัสดุถึงศูนย์คัดแยกสินค้า :SOCW',
        'status': 'N',
        'time': '23.43',
        'date': '8 ก.ค.'
      },
      {
        'title': 'พัสดุออกจากศูนย์คัดแยกสินค้า',
        'status': 'N',
        'time': '19.26',
        'date': '8 ก.ค.'
      },
      {
        'title': 'พัสดุถึงศูนย์คัดแยกสินค้า :FBBON - บางบอน',
        'status': 'N',
        'time': '16.03',
        'date': '8 ก.ค.'
      },
      {
        'title': 'บริษัทขนส่งเข้ารับพัสดุเรียบร้อยแล้ว',
        'status': 'N',
        'time': '14.03',
        'date': '8 ก.ค.'
      },
      {
        'title': 'ผู้ส่งกำลังเตรียมพัสดุ',
        'status': 'N',
        'time': '21.02',
        'date': '7 ก.ค.'
      },
    ];
    // for (var i = 1; i < 10; i++) {
    //   modelT.add({
    //     'title': 'พัสดุถูกจัดส่งสำเร็จแล้ว',
    //     'status': i < 2 ? 'A' : 'N',
    //     'time': '23.49',
    //     'date': i.toString() + ' ก.ค.'
    //   });
    // }
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
        backgroundColor: Theme.of(context).backgroundColor,
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  statusText(model[0]['items'][0]['status']),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'หมายเลขติดตามพัสดุ',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'TH019812736937',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' คัดลอก',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 14,
                          color: Colors.greenAccent[700],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  FutureBuilder(
                      future: shippingStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return timelinesProcessOfDelivery(snapshot.data);
                        } else {
                          return Container();
                        }
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // physics: ClampingScrollPhysics(),
  // shrinkWrap: true,

  Widget timelinesProcessOfDelivery(dynamic shipping) {
    return Timeline.tileBuilder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      theme: TimelineThemeData(
        nodePosition: 0,
        connectorTheme: ConnectorThemeData(
          thickness: 3.0,
          color: Color(0xffd3d3d3),
        ),
        indicatorTheme: IndicatorThemeData(
          size: 15.0,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 20.0),
      builder: TimelineTileBuilder.connected(
        contentsBuilder: (_, __) => rowProcessOfDelivery(shipping[__]),
        connectorBuilder: (_, index, __) {
          if (shipping[index]['status']) {
            return SolidLineConnector(color: Color(0xff6ad192));
          } else {
            return SolidLineConnector();
          }
        },
        indicatorBuilder: (_, index) {
          if (shipping[index]['status']) {
            return DotIndicator(
              color: Color(0xff6ad192),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 10.0,
              ),
            );
          } else {
            return OutlinedDotIndicator(
              color: Color(0xffbabdc0),
              backgroundColor: Color(0xffe6e7e9),
            );
          }
        },
        itemExtentBuilder: (_, __) => kTileHeight,
        itemCount: shipping.length,
      ),
    );
  }

  Widget rowProcessOfDelivery(item) {
    Color color = item['status'] ? Color(0xff6ad192) : Color(0xffbabdc0);
    return Row(
      children: [
        SizedBox(width: 10),
        Column(
          children: [
            Text(
              item['date'],
              style: TextStyle(
                fontFamily: 'Kanit',
                color: color,
              ),
            ),
            Text(
              item['time'],
              style: TextStyle(
                fontFamily: 'Kanit',
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            child: Row(
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: color,
                    fontFamily: 'Kanit',
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget statusText(String status) {
    String text = '';
    Color color = Color(0xFF10BC37);
    switch (status) {
      case "A":
        text = 'เสร็จสิ้น';
        color = Color(0xFF10BC37);
        break;
      case "P":
        text = 'อยู่ระหว่างการจัดส่ง';
        color = Color(0xFFE69700);
        break;
      case "V":
        text = 'รอชำระเงิน';
        color = Color(0xFFE69700);
        break;
      case "W":
        text = 'รอการจัดส่ง';
        color = Color(0xFFE69700);
        break;
      case "R":
        text = 'ยกเลิก';
        color = Color(0xFFED5643);
        break;
      default:
        text = '';
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 60,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontFamily: 'Kanit',
          fontSize: 20,
        ),
      ),
    );
  }

  shippingStatus() async {
    List<dynamic> result = [];
    dynamic approve;
    dynamic pending;
    dynamic waiting;
    dynamic verify;
    dynamic reject;
    dynamic data = await postDio(server + 'm/shipping/read',
        {'reference': model[0]['items'][0]['orderNo']});
    String status = 'V';
    if (data['verify']) status = 'V';
    if (data['waiting']) status = 'W';
    if (data['pending']) status = 'P';
    if (data['approve']) status = 'A';
    if (data['reject']) status = 'R';

    verify = {
      'title': 'รอชำระเงิน',
      'status': false,
      'time': dateStringToTime(data['verifyDate']),
      'date': dateStringToMonthTH(data['verifyDate'])
    };
    waiting = {
      'title': 'ผู้ส่งกำลังเตรียมพัสดุ',
      'status': false,
      'time': dateStringToTime(data['waitingDate']),
      'date': dateStringToMonthTH(data['waitingDate'])
    };
    pending = {
      'title': 'บริษัทขนส่งเข้ารับพัสดุเรียบร้อยแล้ว',
      'status': false,
      'time': dateStringToTime(data['pendingDate']),
      'date': dateStringToMonthTH(data['pendingDate'])
    };
    approve = {
      'title': 'พัสดุถูกจัดส่งสำเร็จแล้ว',
      'status': false,
      'time': dateStringToTime(data['approveDate']),
      'date': dateStringToMonthTH(data['approveDate'])
    };
    reject = {
      'title': 'ยกเลิก',
      'status': false,
      'time': dateStringToTime(data['rejectDate']),
      'date': dateStringToMonthTH(data['rejectDate'])
    };

    switch (status) {
      case 'W':
        waiting['status'] = data['waiting'];
        return [waiting];
        break;
      case 'P':
        pending['status'] = data['pending'];
        return [pending, waiting];
        break;
      case 'A':
        approve['status'] = data['approve'];
        return [approve, pending, waiting];
        break;
      case 'R':
        reject['status'] = data['reject'];
        return [reject];
        break;
      default:
        return [verify];
    }
  }
}
