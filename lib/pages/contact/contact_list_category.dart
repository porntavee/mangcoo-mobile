import 'package:wereward/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:wereward/component/carousel_banner.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/pages/contact/contact_list_category_vertical.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ContactListCategory extends StatefulWidget {
  ContactListCategory({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ContactListCategory createState() => _ContactListCategory();
}

class _ContactListCategory extends State<ContactListCategory> {
  ContactListCategoryVertical contact;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch = '';
  String category = '';

  Future<dynamic> _futureBanner;
  Future<dynamic> _futureCategoryContact;
  final storage = new FlutterSecureStorage();
  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _read();
  }

  _read() async {
    // var profileCode = await storage.read(key: 'profileCode10');
    // if (profileCode != '' && profileCode != null) {
    setState(() {
      _futureCategoryContact = postDio('${contactCategoryApi}read', {
        'skip': 0,
        'limit': 999,
        // 'profileCode': profileCode,
      });
      _futureBanner = postDio('${contactBannerApi}read', {
        'skip': 0,
        'limit': 50,
        'contactPage': true
        // 'profileCode': profileCode,
      });
    });
    // }
  }

  void goBack() async {
    Navigator.pop(context, true);
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
        backgroundColor: Colors.white,
        appBar: header(
          context,
          title: widget.title,
          isShowLogo: false,
          isCenter: true,
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            // controller: _controller,
            children: [
              CarouselBanner(
                model: _futureBanner,
                url: 'contact/',
              ),
              SizedBox(height: 10),
              ContactListCategoryVertical(
                site: "DDPM",
                model: _futureCategoryContact,
                title: "",
                url: '${contactCategoryApi}read',
              ),
              // contact
              // Expanded(
              //   child: contact,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
