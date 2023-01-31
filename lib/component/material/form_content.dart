import 'package:clipboard/clipboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/carousel_form.dart';
import 'package:wereward/component/carousel_rotation.dart';
import 'package:wereward/component/gallery_view.dart';
import 'package:wereward/component/link_url_in.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/component/material/dot_widget.dart';
import 'package:wereward/dark_mode.dart';
import 'package:wereward/login.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'package:wereward/component/button_close_back.dart';
import 'package:wereward/pages/blank_page/blank_loading.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:provider/provider.dart';
import 'package:wereward/widget/dialog.dart';

class FormContent extends StatefulWidget {
  FormContent({
    Key key,
    this.model,
    this.api: '',
    this.urlRotation,
    this.isReward = true,
    this.readOnly = false,
  }) : super(key: key);
  final dynamic model;
  final String api;
  final String urlRotation;
  final bool isReward;
  final bool readOnly;

  @override
  _FormContentState createState() => _FormContentState();
}

class _FormContentState extends State<FormContent> {
  _FormContentState({this.code});
  bool clickArrow = false;

  final storage = new FlutterSecureStorage();
  String profileCode = "";

  Future<dynamic> _futureModel;
  Future<dynamic> _futureRotation;
  // String _urlShared = '';
  String code;
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];
  bool like = false;

  String selectedType = '0';

  @override
  void initState() {
    super.initState();
    readGallery();
    _futureModel = postDio(server + 'm/' + widget.api + '/read',
        {'skip': 0, 'limit': 1, 'code': widget.model['code']});
    _futureRotation = postDio(widget.urlRotation, {'limit': 10});
  }

  Future<dynamic> readGallery() async {
    profileCode = await storage.read(key: 'profileCode10');

    // final result =
    //     await postDio(privilegeGalleryApi, {'code': widget.model['code']});

    final result = await postDio(server + 'm/' + widget.api + '/gallery/read',
        {'code': widget.model['code']});

    // if (result['status'] == 'S') {
    List data = [];
    List<ImageProvider> dataPro = [];

    for (var item in result) {
      data.add(item['imageUrl']);

      dataPro.add(
          item['imageUrl'] != null ? NetworkImage(item['imageUrl']) : null);
    }
    setState(() {
      urlImage = data;
      urlImageProvider = dataPro;
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    // ));
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
        body: FutureBuilder<dynamic>(
          future: _futureModel, // function where you call your api
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            // AsyncSnapshot<Your object type>

            if (snapshot.hasData) {
              return myContent(snapshot.data[0]);
            } else {
              if (widget.model != null && !widget.readOnly) {
                return myContent(widget.model);
              } else {
                return BlankLoading();
              }
            }
          },
        ),
      ),
    );
  }

  myContent(dynamic model) {
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [
      model['imageUrl'] != null ? NetworkImage(model['imageUrl']) : null
    ];

    like = model['like'];
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                child: GalleryView(
                  imageUrl: [...image, ...urlImage],
                  imageProvider: [...imagePro, ...urlImageProvider],
                ),
              ),
              Positioned(
                right: 0,
                top: MediaQuery.of(context).padding.top + 5,
                child: Container(
                  child: buttonCloseBack(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: model['imageUrlCreateBy'] != null
                      ? NetworkImage(model['imageUrlCreateBy'])
                      : null,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${model['referenceShopName']}',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        model['title'],
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              like = !like;
                            });
                            postDio(
                              server + 'm/like/check',
                              {
                                'reference': model['code'],
                                'isActive': like,
                                'category': model['category'],
                              },
                            );
                          },
                          child: Image.asset(
                            like
                                ? 'assets/images/heart_full.png'
                                : 'assets/images/heart.png',
                            height: 20,
                            width: 20,
                            color: like ? Colors.red : Colors.black,
                          ),
                        );
                      },
                    ),
                    // SizedBox(width: 5),
                    // Image.asset(
                    //   'assets/images/bookmark.png',
                    //   height: 20,
                    //   width: 20,
                    //   color: Colors.black,
                    // )
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(
              right: 10,
              left: 10,
            ),
            child: Html(
              data: model['description'],
              onLinkTap: (String url, RenderContext context,
                  Map<String, String> attributes, element) {
                launch(url);
                // open url in a webview
              },
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          if (model['linkUrl'] != null && model['linkUrl'] != '')
            InkWell(
              onTap: () {
                if (model['isPostHeader'] == true) {
                  if (model['isPostHeader']) {
                    if (profileCode != '') {
                      var path = model['linkUrl'];
                      var code = model['code'];
                      var splitCheck = path.split('').reversed.join();
                      if (splitCheck[0] != "/") {
                        path = path + "/";
                      }
                      var codeReplae = "P" +
                          profileCode.replaceAll('-', '') +
                          code.replaceAll('-', '');
                      launchInWebViewWithJavaScript('$path$codeReplae');
                    }
                  }
                } else
                  launchInWebViewWithJavaScript(model['linkUrl']);
                // launchURL(path);
                // launchURL(model['linkUrl']);
                // toastFail(context, text: 'ไปยังเว็บไซต์');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 280,
                ),
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    // 'ไปยังเว็บไซต์',
                    model['textButton'],
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: 10),
          _buildReceive(model),
          SizedBox(
            height: 20.0,
          ),
          if (widget.urlRotation != '')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildRotation(),
              ),
            ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  _buildReceive(model) {
    if (!widget.readOnly)
      return model['allReward'] == model['usedReward']
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              constraints: BoxConstraints(
                minWidth: 100,
                maxWidth: 280,
              ),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'สิทธ์หมดแล้ว',
                  // model['textButton'],
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
            )
          : widget.isReward
              ? InkWell(
                  onTap: () {
                    if (profileCode == null || profileCode == '') {
                      dialog(context,
                          title: 'แจ้งเตือนจากระบบ',
                          description: 'กรุณาเข้าสู่ระบบเพื่อรับสิทธิ์',
                          btnOk: "เข้าสู่ระบบ",
                          isYesNo: true, callBack: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage(),
                          ),
                        );
                      });
                    } else {
                      _buildDialog(model);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    constraints: BoxConstraints(
                      minWidth: 100,
                      maxWidth: 280,
                    ),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'กดรับคูปอง',
                        // model['textButton'],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    constraints: BoxConstraints(
                      minWidth: 100,
                      maxWidth: 280,
                    ),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFA9A9A9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'กดรับคูปอง',
                        // model['textButton'],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                  ),
                );
    !widget.isReward
        ? Container(
            padding: const EdgeInsets.only(
              top: 5,
              right: 10,
              left: 10,
            ),
            child: Text(
              'คะแนนของท่านไม่เพียงพอในการรับสิทธิ์',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w500,
                  color: Color(0XFFFF0000)),
            ),
          )
        : Container();
  }

  _buildRotation() {
    return Container(
      // padding: EdgeInsets.only(left: 15, right: 15, top: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CarouselRotation(
          model: _futureRotation,
          nav: (String path, String action, dynamic model, String code) {
            if (action == 'out') {
              if (model['isPostHeader']) {
                if (profileCode != '') {
                  var path = model['linkUrl'];
                  var code = model['code'];
                  var splitCheck = path.split('').reversed.join();
                  if (splitCheck[0] != "/") {
                    path = path + "/";
                  }
                  var codeReplae = "P" +
                      profileCode.replaceAll('-', '') +
                      code.replaceAll('-', '');
                  launchInWebViewWithJavaScript('$path$codeReplae');
                  // launchURL(path);
                }
              } else
                launchInWebViewWithJavaScript(path);
              // launchURL(path);
            } else if (action == 'in') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarouselForm(
                    code: code,
                    model: model,
                    url: mainBannerApi,
                    urlGallery: bannerGalleryApi,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _buildDialog(dynamic model) async {
    return await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        final themeChange = Provider.of<DarkThemeProvider>(context);
        return CustomAlertDialog1(
          contentPadding: EdgeInsets.all(20),
          content: FutureBuilder(
            future: postDio(
              server + 'm/redeem/check',
              {
                'category': model['category'],
                'page': widget.api,
                'reference': model['code']
              },
            ),
            builder: (context, redeem) {
              // print(redeem);
              if (redeem.hasData) {
                if (redeem.data['code'] == '0') {
                  return Container(
                    height: 340,
                    alignment: Alignment.center,
                    child: Text('สิทธิ์หมดแล้ว'),
                  );
                } else if (redeem.data['code'] == '1') {
                  return Container(
                    height: 340,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Text(
                      'คุณรับได้รับสิทธิ์แล้ว',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else if (redeem.data['code'] == '-99') {
                  return Container(
                    height: 340,
                    alignment: Alignment.center,
                    child: Text('คะแนนของท่านไม่พอรับสิทธิ์'),
                  );
                } else
                  return _buildContentPopUp(model, redeem, themeChange);
              } else {
                return Container(
                  height: 340,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 7.0,
                  ),
                );
              }
            },
          ),
        );
      },
    ).then((val) {
      setState(() {});
    });
  }

  Container _buildContentPopUp(model, redeem, DarkThemeProvider themeChange) {
    return Container(
      height: 400,
      width: MediaQuery.of(context).size.width,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  'คุณได้รับคูปองแล้ว',
                  style: TextStyle(
                      fontFamily: 'Kanit',
                      // fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                // padding: EdgeInsets.only(left: 50),
                child: buttonCloseBack(context),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            child: Text(
              model['title'],
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            child: Text(
              parseHtmlString(model['description']),
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 20),
          DotHorizonWidget(
            totalWidth: (69 * MediaQuery.of(context).size.width) / 100,
            dashColor: Colors.black,
            dashHeight: 1,
            dashWidth: 10,
          ),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        themeChange.darkTheme = themeChange.darkTheme;
                        selectedType = '0';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: selectedType == '0'
                            ? Color(0xFFE84C10)
                            : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'รหัส',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: InkWell(
                //     onTap: () {
                //       setState(() {
                //         themeChange.darkTheme = themeChange.darkTheme;
                //         selectedType = '1';
                //       });
                //     },
                //     child: Container(
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(15),
                //         color: selectedType == '1'
                //             ? Color(0xFFE84C10)
                //             : Colors.transparent,
                //       ),
                //       alignment: Alignment.center,
                //       child: Text(
                //         'บาร์โค๊ด',
                //         style: TextStyle(
                //           fontFamily: 'Kanit',
                //           fontSize: 15,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        themeChange.darkTheme = themeChange.darkTheme;
                        selectedType = '2';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: selectedType == '2'
                            ? Color(0xFFE84C10)
                            : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'QR Code',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: selectedType == '0' ? 25 : 5),
          redeemBox(model, redeem, selectedType),
          SizedBox(height: selectedType == '0' ? 75 : 5),
          Center(
            child: Text(
              'ข้อมูลเพิ่มเติม',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  redeemBox(dynamic model, snapshot, String selectedType) {
    return selectedType == '0'
        ? Container(
            alignment: Alignment.center,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      snapshot.data['code'],
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: GestureDetector(
                    child: Image.asset(
                      'assets/images/double_paper.png',
                      height: 25,
                      width: 25,
                    ),
                    onTap: () async {
                      await FlutterClipboard.copy(snapshot.data['code']).then(
                        (value) => toastFail(context, text: '✓  คัดลอกสำเร็จ'),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        : selectedType == '1'
            ? Center(
                child: loadingImageNetwork(
                    'https://riverplus.com/wp-content/uploads/2011/06/barcode.jpg',
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.fill),
              )
            : selectedType == '2'
                ? Center(
                    // fixflutter2 child: QrImage(
                    //   data: snapshot.data['code'],
                    //   version: QrVersions.auto,
                    //   size: 130.0,
                    // ),
                    )
                : Container();
  }
}
