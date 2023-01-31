import 'package:wereward/component/list_button_horizontal.dart';
import 'package:wereward/pages/contact/contact_list_category.dart';
import 'package:wereward/shop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildContact extends StatefulWidget {
  BuildContact({Key key, this.menuModel, this.model}) : super(key: key);

  final Future<dynamic> model;
  final Future<dynamic> menuModel;

  @override
  BuildContactState createState() => BuildContactState();
}

class BuildContactState extends State<BuildContact> {
  dynamic _tempModel = {'imageUrl': '', 'firstName': '', 'lastName': ''};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: widget.menuModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return screen(snapshot.data, false);
          } else if (snapshot.hasError) {
            return Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor,
                  ],
                ),
              ),
              height: 90,
              child: Center(
                child: Text('Network ขัดข้อง'),
              ),
            );
          } else {
            return screen(_tempModel, true);
          }
        });
  }

  ListButtonHorizontal screen(dynamic model, bool isLoading) {
    var title = isLoading ? 'สมุดโทรศัพท์' : model[7]['title'];
    var imageUrl = isLoading ? '' : model[7]['imageUrl'];

    return ListButtonHorizontal(
      title: 'Shop',
      imageUrl: imageUrl,
      model: widget.model,
      navigationList: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopPage(),
          ),
        );
      },
      navigationForm: (String phone) {
        showDialog(
          context: context,
          builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text(
              phone,
              style: TextStyle(
                // fontWeight: FontWeight.normal,
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
              ),
            ),
            content: Text(" "),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text(
                  "ยกเลิก",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    fontFamily: 'Kanit',
                    color: Color(0xFF6C6C6C),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text(
                  "โทร",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    fontFamily: 'Kanit',
                    color: Color(0xFF9A1120),
                  ),
                ),
                onPressed: () => launch("tel://" + phone),
              ),
            ],
          ),
        );
      },
    );
  }

  // .end
}
