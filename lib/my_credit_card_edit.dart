import 'package:flutter/material.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'widget/header.dart';
import 'widget/text_form_field.dart';

class MyCreditCardEditPage extends StatefulWidget {
  MyCreditCardEditPage({Key key, this.code: ''}) : super(key: key);

  final String code;
  @override
  _MyCreditCardEditPageState createState() => _MyCreditCardEditPageState();
}

class _MyCreditCardEditPageState extends State<MyCreditCardEditPage> {
  dynamic model;
  Future<dynamic> futureModel;
  bool isActive = false;
  bool isDefault = false;

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  var tempData = List<dynamic>();

  @override
  void initState() {
    if (widget.code != '') _callRead();
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
        appBar: header2(
          context,
          title: 'จัดการบัตรเครดิต',
        ),
        backgroundColor: Colors.white,
        body: buildFutureBuilder(),
      ),
    );
  }

  buildFutureBuilder() {
    return FutureBuilder(
      future: futureModel,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildList(snapshot.data[0]);
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _callRead());
        } else {
          return Container();
        }
      },
    );
  }

  _buildList(model) {
    String textDefault = model['isDefault'] ? '[ค่าเริ่มต้น]' : '';
    return Column(
      children: [
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'บัตรเครดิตของฉัน *' + model['number'],
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'สถานะ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('[ค่าเริ่มต้น]',
                  style: TextStyle(fontFamily: 'Kanit', fontSize: 15)),
              Switch(
                value: model['isDefault'],
                onChanged: (value) {
                  setState(() {
                    model['isDefault'] = value;
                  });
                  update(model);
                },
                activeTrackColor: Theme.of(context).accentColor,
                activeColor: Color(0xFFFFFFFF),
              )
            ],
          ),
        ),
        SizedBox(height: 60),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 35,
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFF707070),
              child: MaterialButton(
                onPressed: () {
                  delete();
                },
                child: new Text(
                  'ลบข้อมูลบัตรเครดิต',
                  style: new TextStyle(
                    fontSize: 13.0,
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
    );
  }

  _callRead() {
    setState(() {
      futureModel = postDio('${server}m/manageCreditCard/read', {
        "code": widget.code,
      });
    });
  }

  update(param) {
    postDio('${server}m/manageCreditCard/update', {
      "code": param['code'],
      "isDefault": param['isDefault'],
    }).then((value) => {});
  }

  delete() async {
    await postDio('${server}m/manageCreditCard/delete', {
      "code": widget.code,
    }).then((value) => {Navigator.pop(context, 'success')});
  }
}
