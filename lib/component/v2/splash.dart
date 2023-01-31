import 'dart:async';
import 'package:wereward/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/login.dart';
import 'package:wereward/pages/blank_page/dialog_fail.dart';
import 'package:wereward/shared/api_provider.dart';

import '../../home_mart.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _urlImage = '';
  int _timeOut = 0;
  Future<dynamic> _futureModel;

  @override
  void initState() {
    _read();
    // futureModel = getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasError)
            return Center(
              child: Container(
                color: Colors.white,
                child: dialogFail(context, reloadApp: true),
              ),
            );
          else
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: new Image.network(
                    snapshot.data[0]['imageUrl'],
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  _read() async {
    _futureModel = postDio(splashReadApi, {});
  }

  startTime(time) async {
    var _duration = new Duration(seconds: time);
    return new Timer(_duration, navigationPage);
  }

  Future<void> navigationPage() async {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: 'dataUserLoginDDPM');

    if (value != null && value != '') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeMartPage(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<dynamic> getImage() async {
    final result = await postObjectData('m/splash/read', {});
    // print(
    //     '----------------------getImage-------------------${result['status']}');
    if (result['status'] == 'S') {
      setState(() {
        _urlImage = result['objectData'][0]['imageUrl'] ?? null;
        _timeOut = int.parse(result['objectData'][0]['timeOut'] ?? 0);
      });
      int _time = (_timeOut / 1000).round();
      assert(_time is int);

      startTime(_time);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
