import 'package:flutter/material.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/widget/stack_tap.dart';

class PaymentCreditSuccess extends StatelessWidget {
  const PaymentCreditSuccess({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeMartPage()),
              (Route<dynamic> route) => false);
        } else if (details.delta.dx < -0) {
          //Left Swipe
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeMartPage()),
              (Route<dynamic> route) => false);
          ;
        }
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 100),
              Container(
                height: 130,
                width: 130,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Container(
                  height: 110,
                  width: 110,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    height: 90,
                    width: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green[200],
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      height: 70,
                      width: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 150),
              Text(
                'ชำระเงินสำเร็จ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 20,
                  color: Colors.greenAccent,
                ),
              ),
              // Text(
              //   'เลข order : ' + widget.code,
              //   style: TextStyle(
              //     fontFamily: 'Kanit',
              //     fontSize: 13,
              //     color: Colors.grey,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              SizedBox(height: 100),
              Expanded(child: Container()),
              StackTap(
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeMartPage()),
                  (Route<dynamic> route) => false,
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 35,
                  width: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'กลับ',
                    style: TextStyle(
                        fontFamily: 'Kanit', fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
