import 'package:flutter/material.dart';
import 'package:wereward/models/user.dart';
import 'package:wereward/shared/extension.dart';

class SSOListCardHorizontal extends StatefulWidget {
  SSOListCardHorizontal({Key key, this.userData}) : super(key: key);
  final User userData;

  @override
  _SSOListCardHorizontal createState() => _SSOListCardHorizontal();
}

class _SSOListCardHorizontal extends State<SSOListCardHorizontal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userData != null) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        // decoration: BoxDecoration(
        //     color: Colors.amber,
        //     border: Border.all(color: Colors.white),
        //     gradient: LinearGradient(colors: [Colors.amber, Colors.yellow])),
        height: 160,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(
              width: 5.0,
            ),
            widget.userData.countUnit != ''
                ? myCard(
                    'ยอดเงินสมทบชราภาพ',
                    'ณ ปัจจุบัน',
                    134145,
                    'บาท',
                    '',
                    LinearGradient(
                        colors: [Color(0xFF000070), Color(0xFF0191B4)]))
                : myCardUnActivate(
                    context,
                    'ยอดเงินสมทบชราภาพ',
                    'กรุณาเชื่อมต่อระบบผู้ประกันตน เพื่อแสดงข้อมูล',
                    LinearGradient(
                        colors: [Color(0xFF000070), Color(0xFF0191B4)]),
                    LinearGradient(
                        colors: [Color(0xFFFFC324), Color(0xFFFE9019)])),
            widget.userData.countUnit != ''
                ? myCard(
                    'สิทธิ์ทันตกรรม',
                    'ณ ปัจจุบัน',
                    900,
                    'บาท',
                    '',
                    LinearGradient(
                        colors: [Color(0xFFFFC324), Color(0xFFFE9019)]))
                : myCardUnActivate(
                    context,
                    'สิทธิ์ทันตกรรม',
                    'กรุณาเชื่อมต่อระบบผู้ประกันตน เพื่อแสดงข้อมูล',
                    LinearGradient(
                        colors: [Color(0xFFFFC324), Color(0xFFFE9019)]),
                    LinearGradient(
                        colors: [Color(0xFF000070), Color(0xFF0191B4)])),
            myCard(
                'บริการออนไลน์',
                'E-Service',
                0,
                '',
                'assets/images/e-service.png',
                LinearGradient(colors: [Color(0xFF0191B4), Color(0xFF000070)])),
            SizedBox(
              width: 5.0,
            ),
          ],
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        // decoration: BoxDecoration(
        //     color: Colors.amber,
        //     border: Border.all(color: Colors.white),
        //     gradient: LinearGradient(colors: [Colors.amber, Colors.yellow])),
        height: 160,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(
              width: 5.0,
            ),
            myCardUnActivate(
                context,
                'ยอดเงินสมทบชราภาพ',
                'กรุณาเชื่อมต่อระบบผู้ประกันตน เพื่อแสดงข้อมูล',
                LinearGradient(colors: [Color(0xFF000070), Color(0xFF0191B4)]),
                LinearGradient(colors: [Color(0xFFFFC324), Color(0xFFFE9019)])),
            myCardUnActivate(
                context,
                'สิทธิ์ทันตกรรม',
                'กรุณาเชื่อมต่อระบบผู้ประกันตน เพื่อแสดงข้อมูล',
                LinearGradient(colors: [Color(0xFFFFC324), Color(0xFFFE9019)]),
                LinearGradient(colors: [Color(0xFF000070), Color(0xFF0191B4)])),
            myCard(
                'บริการออนไลน์',
                'E-Service',
                0,
                '',
                'assets/images/e-service.png',
                LinearGradient(colors: [Color(0xFF0191B4), Color(0xFF000070)])),
            SizedBox(
              width: 5.0,
            ),
          ],
        ),
      );
    }
  }
}

myCard(
  String title,
  String subTitle,
  int qty,
  String unit,
  String image,
  LinearGradient color,
) {
  return Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.only(left: 5, right: 5),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: Colors.amber,
      // border: Border.all(color: Colors.white.withAlpha(150)),
      borderRadius: BorderRadius.circular(20),
      gradient: color,
    ),
    width: 280,
    height: 160,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        Text(
          subTitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontFamily: 'Kanit',
            // fontWeight: FontWeight.bold,
          ),
        ),
        qty != 0
            ? Container(
                padding: EdgeInsets.only(top: 5),
                alignment: Alignment.centerRight,
                child: Text(
                  moneyFormat(qty.toString()),
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                  ),
                ),
              )
            : Container(),
        unit != ''
            ? Container(
                alignment: Alignment.centerRight,
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                  ),
                ),
              )
            : Container(),
        image != ''
            ? Container(
                alignment: Alignment.centerRight,
                height: 65,
                child: Image.asset(image),
              )
            : Container(),
      ],
    ),
  );
}

myCardUnActivate(
  BuildContext context,
  String title,
  String subTitle,
  LinearGradient colorBackgroud,
  LinearGradient colorButton,
) {
  return Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.only(left: 5, right: 5),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: Colors.amber,
      // border: Border.all(color: Colors.white.withAlpha(150)),
      borderRadius: BorderRadius.circular(20),
      gradient: colorBackgroud,
    ),
    width: 280,
    height: 160,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
          padding: EdgeInsets.only(left: 30, right: 30),
          child: Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 86,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: colorButton,
              ),
              child: MaterialButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ConnectSSOPage(goHome: true),
                  //   ),
                  // );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'คลิกที่นี่',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    ),
  );
}

//
// class SSOListCardHorizontal extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       padding: EdgeInsets.only(top: 10, bottom: 10),
//       // decoration: BoxDecoration(
//       //     color: Colors.amber,
//       //     border: Border.all(color: Colors.white),
//       //     gradient: LinearGradient(colors: [Colors.amber, Colors.yellow])),
//       height: 160,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: [
//           myCard('ยอดเงินสมทบชราภาพ', 'ณ ปัจจุบัน', 134145, 'บาท', '',
//               LinearGradient(colors: [Color(0xFF000070), Color(0xFF0191B4)])),
//           myCard('สิทธิ์ทันตกรรม', 'ณ ปัจจุบัน', 900, 'บาท', '',
//               LinearGradient(colors: [Color(0xFFFFC324), Color(0xFFFE9019)])),
//           myCard(
//               'สิทธิ์ทันตกรรม',
//               'ณ ปัจจุบัน',
//               0,
//               '',
//               'assets/images/e-service.png',
//               LinearGradient(colors: [Color(0xFF0191B4), Color(0xFF000070)])),
//         ],
//       ),
//     );
//   }
// }
