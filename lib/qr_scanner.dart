import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewPage extends StatefulWidget {
  const QRViewPage({
    Key key,
    this.model,
  }) : super(key: key);

  final dynamic model;

  @override
  State<StatefulWidget> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  final storage = new FlutterSecureStorage();
  String profileCode = '';
  Barcode result;
  var code = '';
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildQrView(context),
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 40,
            child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Platform.isAndroid
              ? Positioned(
                  top: MediaQuery.of(context).padding.top + 40,
                  right: 40,
                  child: GestureDetector(
                    onTap: () async {
                      await controller?.toggleFlash();
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(10),
                      child: FutureBuilder(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return Icon(
                            snapshot.data ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  _setCode() async {
    var pCode = await storage.read(key: 'profileCode10');
    setState(() {
      code = result.code;
    });

    return await postDio(
      server + 'm/redeem/shop/read',
      {'code': code, 'profileCode': pCode},
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
        code = result.code;
      });
      await controller?.pauseCamera();
      var data = await _setCode();
      if (data.length > 0) {
        return _buildDialog(data[0]);
      } else {
        return _buildDialog({'status': 'F'});
      }
    });
  }

  _buildDialog(dynamic model) async {
    bool isNotUsed = true;
    var title = model['status'] == 'A'
        ? 'สิทธิ์นี้ถูกใช้ไปแล้ว'
        : model['status'] == 'F'
            ? 'QR Code ไม่ถูกต้อง'
            : ' ';

    if (model['status'] != 'N') {
      isNotUsed = false;
    }
    return await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false, // close outside
      context: context,
      builder: (_) {
        return CustomAlertDialog1(
          contentPadding: EdgeInsets.all(10),
          content: Container(
            height: isNotUsed ? 200 : 100,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isNotUsed)
                  Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              'กรุณายืนยันการรับสิทธิ์',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              model['title'],
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Image.network(
                                  model['imageUrl'],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        )),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(
                      title: isNotUsed ? 'ยกเลิก' : 'ตกลง',
                      color: isNotUsed ? Colors.grey : Colors.red,
                      press: () async {
                        await controller?.resumeCamera();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                    if (isNotUsed) SizedBox(width: 20),
                    if (isNotUsed)
                      _buildButton(
                        title: 'ตกลง',
                        press: () {
                          postDio(server + 'm/redeem/receive', {
                            'code': model['code'],
                          }).then((value) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },
                      )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Stack _buildButton(
      {String title = "", Function press, Color color = Colors.red}) {
    return Stack(
      children: [
        Container(
          height: 35,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () => press(),
          ),
        )
      ],
    );
  }
}
