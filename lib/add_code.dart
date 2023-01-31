import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wereward/widget/text_form_field.dart';

class CodeViewPage extends StatefulWidget {
  const CodeViewPage({
    Key key,
    this.model,
  }) : super(key: key);

  final dynamic model;

  @override
  State<StatefulWidget> createState() => _CodeViewPageState();
}

class _CodeViewPageState extends State<CodeViewPage> {
  final storage = new FlutterSecureStorage();
  String profileCode = '';
  var code = '';
  TextEditingController controller;
  TextEditingController txtCode = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    txtCode = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBackground();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _buildBackground() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      child: _buildScaffold(),
    );
  }

  _buildScaffold() {
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
        backgroundColor: Colors.transparent,
        appBar: header(context, goBack, title: ''),
        body: ListView(
          children: <Widget>[
            new Container(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                            child: Text(
                              'กรุณากรอก Code ที่ต้องการใช้',
                              style: TextStyle(
                                fontSize: 18.00,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          labelTextFormField('Code'),
                          textFormField(
                            txtCode,
                            null,
                            'Code',
                            'Code',
                            true,
                            false,
                            false,
                          ),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              margin: EdgeInsets.only(
                                top: 20.0,
                                bottom: 10.0,
                              ),
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(10.0),
                                color: Theme.of(context).primaryColor,
                                child: MaterialButton(
                                  height: 40,
                                  onPressed: () {
                                    final form = _formKey.currentState;
                                    if (form.validate()) {
                                      _onCodeViewCreated();
                                    }
                                  },
                                  child: new Text(
                                    'ยืนยัน',
                                    style: new TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Kanit',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _setCode() async {
    // print('txtCode.text ====');
    // print(txtCode.text);
    var pCode = await storage.read(key: 'profileCode10');
    setState(() {
      code = txtCode.text;
    });

    var result = await postDio(
      server + 'm/redeem/shop/read',
      {'code': code, 'profileCode': pCode},
    );
    return result;
  }

  void _onCodeViewCreated() async {
    var data = await _setCode();
    if (data.length > 0) {
      return _buildDialog(data[0]);
    } else {
      return _buildDialog({'status': 'F'});
    }
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
