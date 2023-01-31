import 'package:flutter/material.dart';
import 'package:wereward/models/user.dart';

class ButtonMenuFull extends StatefulWidget {
  ButtonMenuFull(
      {Key key,
      this.title,
      this.imageUrl,
      this.userData,
      this.nav,
      this.model,
      this.subTitle})
      : super(key: key);

  final String title;
  final String imageUrl;
  final User userData;
  final Function nav;
  final String subTitle;
  final Future<dynamic> model;

  @override
  _ButtonMenuFull createState() => _ButtonMenuFull();
}

class _ButtonMenuFull extends State<ButtonMenuFull> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: widget.model,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return InkWell(
              onTap: () {
                widget.nav();
              },
              child: InkWell(
                onTap: widget.nav,
                child: myCard(
                  title: widget.title,
                  imageUrl: widget.imageUrl,
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  myCard({String title = '', String subTitle = '', String imageUrl = ''}) {
    // double height = MediaQuery.of(context).size.height;
    return Container(
      // padding: EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        // image: DecorationImage(
        //   image: NetworkImage(imageUrl),
        //   fit: BoxFit.fill,
        // ),
      ),
      child: Image.network(imageUrl),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text(
      //       title,
      //       style: TextStyle(
      //         fontSize: 13.0,
      //         color: Colors.white,
      //         fontWeight: FontWeight.w500,
      //         fontFamily: 'Kanit',
      //         // shadows: <Shadow>[
      //         //   Shadow(
      //         //     offset: Offset(0.0, 1.0),
      //         //     blurRadius: 5,
      //         //     color: Colors.grey,
      //         //   ),
      //         // ],
      //       ),
      //     ),
      //     Text(
      //       subTitle,
      //       style: TextStyle(
      //         fontSize: height * 1.5 / 100,
      //         color: Colors.white,
      //         fontFamily: 'Kanit',
      //         shadows: <Shadow>[
      //           Shadow(
      //             offset: Offset(0.0, 1.0),
      //             blurRadius: 5,
      //             color: Colors.grey,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
