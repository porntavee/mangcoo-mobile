import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signalr_client/signalr_client.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_payment.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/stack_tap.dart';

class QRPayment extends StatefulWidget {
  QRPayment({Key key, this.code: '', this.back: true}) : super(key: key);

  final String code;
  final bool back;

  @override
  State<StatefulWidget> createState() => QRPaymentState();
}

class QRPaymentState extends State<QRPayment> {
  GlobalKey globalKey = new GlobalKey();
  final serverUrl = "https://core148.we-builds.com/payment-api/payment";
  HubConnection hubConnection;
  String albumName = appName;
  String qrCode = '';
  bool checkOrder = false;
  String code = '';
  Timer _timerForInter;
  dynamic modelPayment = {};
  String transaction = '';
  String provider = '';
  var taskId;

  Future<dynamic> _future;

  String currentWidget = '1';

  @override
  void initState() {
    _future = postDio(server + 'paymentlog/read', {'code': widget.code});
    // taskId = await FlutterDownloader.enqueue(
    //   url: 'your download link',
    //   savedDir: 'the path of directory where you want to save downloaded files',
    //   showNotification:
    //       true, // show download progress in status bar (for Android)
    //   openFileFromNotification:
    //       true, // click on notification to open downloaded file (for Android)
    // );

    _timerForInter = Timer.periodic(new Duration(seconds: 5), (timer) async {
      if (transaction != '') {
        dynamic result = {};
        if (provider == 'omise') {
          result =
              await postDio(server + 'paymentlog/read', {'code': widget.code});
          setState(() {
            currentWidget = result['respStatus'].toString();
          });
          if (result['respStatus'] == '2') {
            timer.cancel();
            modelPayment['respStatus'] = "2";
            await postDio(server + 'paymentlog/create', modelPayment);
            await postDio(
              server + 'm/cart/update/status',
              {'code': widget.code, 'status': 'W'},
            );
          }
        } else {
          result = await postPaymentQuery(transaction);
          setState(() {
            currentWidget = result['resStatus'].toString();
          });
          if (result['resStatus'] == 2) {
            // stop period timer.
            timer.cancel();
            modelPayment['respStatus'] = "2";
            // update payment status 2 = success.
            await postDio(server + 'paymentlog/create', modelPayment);
            // update cart status P = waiting for shipping.
            postDio(
              server + 'm/cart/update/status',
              {'code': widget.code, 'status': 'W'},
            );
          }
        }
      }
    });
    super.initState();
    // initSignalR();
  }

  @override
  void dispose() {
    _timerForInter.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context, currentWidget);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
            onPressed: () => {
              if (widget.back)
                Navigator.of(context).pop()
              else
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeMartPage()),
                  (Route<dynamic> route) => false,
                )
            },
          ),
          title: Text(
            'QR Payment',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          brightness: Brightness.light,
        ),
        body: WillPopScope(
          child: futureBuilder(),
          onWillPop: () => Future.value(widget.back),
        ),
      ),
    );
  }

  futureBuilder() {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            modelPayment = snapshot.data;
            if (transaction == '')
              transaction = snapshot.data['respTransaction'];
            if (provider == '') {
              provider = snapshot.data['paymentProvider'];
            }
            return _animatedSwitcher(snapshot.data);
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        });
  }

  _animatedSwitcher(model) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 500),
      child: _buildWidget(model),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastLinearToSlowEaseIn,
            ),
          ),
          child: child,
        );
      },
    );
  }

  _buildWidget(model) {
    return FutureBuilder(
      future: Future.value(currentWidget),
      builder: (context, snapshot) {
        return snapshot.data == '2' ? _buildSuccess() : _buildQRCode(model);
      },
    );
  }

  Column _buildQRCode(model) {
    return Column(
      children: <Widget>[
        Expanded(
          child: RepaintBoundary(
            key: globalKey,
            child: Container(
              alignment: Alignment.topCenter,
              color: Colors.white,
              child: model['respTransaction'].substring(0, 4) == 'chrg'
                  ? Column(
                      children: [
                        loadingImageNetwork(model['respURL']),
                        // Text(
                        //   model['respTransaction'],
                        //   style: TextStyle(
                        //     fontFamily: 'Kanit',
                        //     fontSize: 18,
                        //     color: Colors.green[400],
                        //   ),
                        // ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/thai_qr_payment.png'),
                        SizedBox(height: 10),
                        loadingImageNetwork(model['respURL']),
                        Text(
                          model['respTransaction'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            color: Colors.green[400],
                          ),
                        ),
                        Text(
                          'สแกน QR เพื่อโอนเข้าบัญชี',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            color: Colors.green[400],
                          ),
                        ),
                        Text(
                          appName,
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        Container(height: 1, color: Colors.grey),
        // Container(
        //   height: 140,
        //   width: double.infinity,
        //   // color: Colors.blue,
        //   alignment: Alignment.center,
        //   child: StackTap(
        //     onTap: _captureAndSharePng,
        //     child: Container(
        //       height: 40,
        //       width: 150,
        //       alignment: Alignment.center,
        //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        //       decoration: BoxDecoration(
        //         color: Colors.blue,
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //       child: Text(
        //         'download',
        //         style: TextStyle(
        //           fontFamily: 'Kanit',
        //           fontSize: 15,
        //           color: Colors.white,
        //         ),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  _buildSuccess() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
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
          Text(
            'เลข order : ' + widget.code,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          // Text(
          //   'ราคา : ' + priceFormat.format(widget.model['netPrice']),
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
    );
  }

  Future<void> _captureAndSharePng() async {
    _requestPermission();
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      Directory appDocumentsDirectory = await getTemporaryDirectory();
      // await getExternalStorageDirectory(); // only android.
      // await getApplicationDocumentsDirectory();
      String appExternalStoragePath = appDocumentsDirectory.path;
      var gen = new DateTime.now().millisecondsSinceEpoch.toString();
      final file =
          await new File(appExternalStoragePath + gen + '.png').create();
      await file.writeAsBytes(pngBytes);
      _saved(appExternalStoragePath + gen + '.png');

      // final channel = const MethodChannel('channel:me.alfian.share/share');
      // channel.invokeMethod('shareFile', 'image.png');
    } catch (e) {
      print(e.toString());
    }
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    // toastFail(context, text: info);
  }

  _saved(String image) async {
    await GallerySaver.saveImage(image, albumName: albumName).then((value) {
      setState(() {
        print("File Saved to Gallery");
      });
    });
    toastFail(context, text: 'success !!');
    // await GallerySaver.saveImage(image, albumName: albumName);
    // print("File Saved to Gallery");
  }

  void initSignalR() {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.onclose((error) => print('Connection close'));

    hubConnection.state == HubConnectionState.Disconnected
        ? hubConnection.start()
        : hubConnection.stop();
    hubConnection.on("paymentdata", _handleNewData);

    // if (hubConnection.state == HubConnectionState.Disconnected)
    //   hubConnection.start();
    // else if (hubConnection.state == HubConnectionState.Connected)
    //   hubConnection.stop();
  }

  _handleNewData(dynamic model) {
    var data = model[0]['objectData']
        .firstWhere((e) => code == e['code'], orElse: () => null);
    if (data != null) {
      if (!checkOrder) {
        print('------- code -------');
        print(code);
        postDio(server + 'm/cart/payment/update', {'code': code});
      }

      if (this.mounted)
        setState(() {
          checkOrder = true;
          currentWidget = '2';
          code = '';
        });
    }
  }
}
