import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/cart_list.dart';
import 'package:wereward/component/carousel_form.dart';
import 'package:wereward/component/carousel_rotation.dart';
import 'package:wereward/component/gallery_view.dart';
import 'package:wereward/component/link_url_in.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/menu/list_content_same_product.dart';
import 'package:wereward/confirm_order.dart';
import 'package:wereward/data_error.dart';
import 'package:wereward/login.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'package:wereward/pages/blank_page/blank_loading.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/shop.dart';
import 'package:wereward/widget/nav_animation.dart';

class FormContentShop extends StatefulWidget {
  FormContentShop({
    Key key,
    this.model,
    this.api: '',
    this.urlRotation,
    this.isReward = true,
    this.readOnly = false,
    this.navFrom = '',
  }) : super(key: key);

  final dynamic model;
  final String api;
  final String urlRotation;
  final bool isReward;
  final bool readOnly;
  final String navFrom;

  @override
  _FormContentShopState createState() => _FormContentShopState();
}

class _FormContentShopState extends State<FormContentShop> {
  _FormContentShopState({this.code});
  bool clickArrow = false;

  final storage = new FlutterSecureStorage();
  String profileCode = "";

  Future<dynamic> _futureModel;
  Future<dynamic> _futureModelInventory;
  Future<dynamic> _futureSameProduct;
  Future<dynamic> _futureRotation;
  Future<dynamic> _futureComment;
  // String _urlShared = '';
  String code;
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];
  bool like = false;
  dynamic tempData;
  String shopCode = '';
  String shopName = '';

  String selectedType = '0';

  int productQty = 1;
  int maxProduct = 16;
  String selectedInventory = '';
  int amountItemInCart = 0;

  @override
  void initState() {
    super.initState();
    sendWhat();
    read();
    readGallery();
    _futureComment = postDio(
        server + 'm/goods/comment/read', {'code': widget.model['code']});
    setState(() {
      tempData = {
        'price': 0,
        'netPrice': 0,
        'minPrice': 0,
        'maxPrice': 0,
        'like': false,
        'referenceShopName': '',
        'rating': 0.0,
        ...widget.model
      };
    });
  }

  sendWhat() async {
    var profileCode = await storage.read(key: 'profileCode10');
    var profileFirstName = await storage.read(key: 'profileFirstName');
    var profileLastName = await storage.read(key: 'profileLastName');

    postDio('http://core148.we-builds.com/st-api/api/WeMart/Create', {
      "title": widget.model['title'],
      "profileCode": profileCode,
      "firstName": profileFirstName,
      "lastName": profileLastName,
    });
  }

  read() async {
    profileCode = await storage.read(key: 'profileCode10');
    getCountItemInCart();
    // dynamic
    _futureModelInventory = postDio(
        server + 'm/goods/inventory/read', {'reference': widget.model['code']});

    setState(() {
      // future dynamic
      _futureModel = postDio(server + 'm/goods/read',
          {'skip': 0, 'limit': 1, 'code': widget.model['code']});
      _futureRotation = postDio(rotationNewsApi, {'limit': 10});
      _futureSameProduct = postDio(server + 'm/goods/read', {'limit': 10});
    });
  }

  getCountItemInCart() async {
    //get amount item in cart.
    await postDio(server + 'm/cart/count', {}).then((value) async {
      if (value != null)
        setState(() {
          amountItemInCart = value['count'];
        });
    });
  }

  readGoodsInventory() async {
    return await postDio(
        server + 'm/goods/inventory/read', {'reference': widget.model['code']});
  }

  Future<dynamic> readGallery() async {
    final result = await postDio(
        server + 'm/goods/gallery/read', {'code': widget.model['code']});

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
        body: buildFutureBuilder(),
      ),
    );
  }

  buildFutureBuilder() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: [
              buildDetail(snapshot.data[0]), // detail && same product.
              buildBtnHeader(), // back button, cart page button, other button.
              buildBtnBottom(
                  snapshot.data[0]), // add cart button, buy now button.
            ],
          );
        } else if (snapshot.hasError) {
          return Stack(
            children: [
              DataError(onTap: () => read()),
              buildBtnHeader(), // back button, cart page button, other button.
            ],
          );
        } else {
          if (widget.model != null && !widget.readOnly) {
            return Stack(
              children: [
                buildDetail(tempData), // detail && same product.
                buildBtnHeader(), // back button, cart page button, other button.
              ],
            );
          } else {
            return BlankLoading();
          }
        }
      },
    );
  }

  Positioned buildBtnBottom(model) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 50 + MediaQuery.of(context).padding.bottom,
        width: double.infinity,
        color: Theme.of(context).accentColor,
        child: Row(
          children: [
            InkWell(
              onTap: () => {
                if (profileCode != '' && profileCode != null)
                  {
                    buildModal('cart').then((value) => getCountItemInCart()),
                  }
                else
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                    )
                  }
              },
              child: Container(
                width: 128,
                alignment: Alignment.center,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/cart.png',
                      height: 25,
                      width: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      'เพิ่มไปยังรถเข็น',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => {
                  if (profileCode != '' && profileCode != null)
                    buildModal('buy')
                  else
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                    )
                },
                child: Text(
                  'ซื้อสินค้า',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Positioned buildBtnHeader() {
    return Positioned(
      left: 15,
      right: 15,
      top: MediaQuery.of(context).padding.top + 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () => {
                  if (widget.navFrom == 'cart')
                    Navigator.pop(context)
                  else
                    {
                      if (profileCode != '' && profileCode != null)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartListPage(),
                          ),
                        ).then((value) => getCountItemInCart())
                      else
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage(),
                          ),
                        )
                    }
                },
                child: Stack(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Image.asset('assets/images/cart.png'),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        height: 15,
                        width: 15,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          amountItemInCart.toString(),
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 35,
                height: 35,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Image.asset('assets/images/triple_dot.png'),
              ),
            ],
          )
        ],
      ),
    );
  }

  buildDetail(dynamic model) {
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [
      model['imageUrl'] != null ? NetworkImage(model['imageUrl']) : null
    ];
    shopCode = model['referenceShopCode'];
    shopName = model['referenceShopName'];

    like = model['like'];
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        imageProductView(image, imagePro),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (model['price'] != model['netPrice'])
                      Text(
                        '${priceFormat.format(model['price']) + " บาท"}',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Kanit',
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '${model['minPrice']}' != '${model['maxPrice']}'
                          ? '${priceFormat.format(model['minPrice']) + " - " + priceFormat.format(model['maxPrice']) + " บาท"}'
                          : '${priceFormat.format(model['netPrice']) + " บาท"}',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      highlightColor: Colors.white,
                      onTap: () async {
                        var response = await postDio('${server}m/shop/read',
                            {'code': '${model['referenceShopCode']}'});
                        Navigator.push(
                          context,
                          fadeNav(
                            ShopPage(model: response[0]),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Theme.of(context).accentColor,
                        ),
                        child: Text(
                          // 'we build',
                          '${model['referenceShopName']}',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${model['title']}',
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (model['price'] != model['netPrice']) buildDiscountTag(model)
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ratingBar(model['rating']),
                  SizedBox(width: 5),
                  if (model['rating'] > 0)
                    Text(
                      double.parse(model['rating'].toString())
                              .toStringAsFixed(1) +
                          '/5',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  SizedBox(width: 5),
                  Text(
                    '(' + model['totalComment'].toString() + ' รีวิว)',
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        color: Colors.grey[600]),
                  ),
                ],
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
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 5,
          width: double.infinity,
          color: Theme.of(context).backgroundColor,
        ),
        SizedBox(height: 20),
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(
            right: 10,
            left: 15,
          ),
          child: Text(
            "รายละเอียดสินค้า",
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Html(
            data: '${model['description']}',
            onLinkTap: (String url, RenderContext context,
                Map<String, String> attributes, element) {
              launch(url);
              // open url in a webview
            },
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 5,
          width: double.infinity,
          color: Theme.of(context).backgroundColor,
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildRotation(),
          ),
        ),
        buildSameProduct(),
        _buildReview(),
        Container(
          height: 80 + MediaQuery.of(context).padding.bottom,
          width: double.infinity,
          color: Theme.of(context).backgroundColor,
        ),
      ],
    );
  }

  Container buildDiscountTag(model) {
    String unit = model['disCountUnit'] == 'C' ? ' บาท' : '%';

    return Container(
      height: 65,
      constraints: BoxConstraints(minWidth: 50),
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'ลด\n${model['discount']}' + unit,
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // -------------- widget method
  Stack imageProductView(List image, List<ImageProvider<Object>> imagePro) {
    return Stack(
      children: [
        ClipRRect(
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Container _buildRotation() {
    return Container(
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

  buildSameProduct() {
    return FutureBuilder(
      future: _futureSameProduct,
      builder: (context, partnerData) {
        if (partnerData.hasData) {
          return ListContentSameProduct(
            // key: keyButton6,
            title: 'คุณอาจชอบสิ่งนี้',
            model: _futureSameProduct,
            cardWidth: 140,
            hasImageCenter: false,
            hasDescription: false,
            navigationForm: (dynamic model) {},
          );
        } else if (partnerData.hasError) {
          return Container();
        } else {
          return Container(height: 150);
        }
      },
    );
  }

  buildModal(String type) {
    setState(() {
      productQty = 1;
    });

    return showCupertinoModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return FutureBuilder(
                future: readGoodsInventory(),
                builder: (contect, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      // toastFail(context, text: 'ไม่พบสินค้า', duration: 1);
                      // Navigator.pop(context, true);
                      return Container();
                    }
                    var model = snapshot.data[0];

                    if (selectedInventory != '') {
                      model = snapshot.data
                          .firstWhere((c) => c['code'] == selectedInventory);
                      if (productQty > model['qty']) productQty = model['qty'];
                      if (model['qty'] <= 0) {
                        productQty = 1;
                        model['qty'] = 0;
                      }
                      ;
                    } else {
                      selectedInventory = snapshot.data[0]['code'];
                    }
                    return Material(
                      type: MaterialType.transparency,
                      child: new Container(
                        height: MediaQuery.of(context).size.height * 0.60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 50, 15, 15),
                              child: ListView(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: loadingImageNetwork(
                                          model['imageUrl'],
                                          height: 130,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${model['title']}',
                                              style: TextStyle(
                                                fontFamily: 'Kanit',
                                                fontSize: 13,
                                                color: Colors.black,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (model['price'] !=
                                                model['netPrice'])
                                              Text(
                                                '${priceFormat.format(model['price']) + " บาท"}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Kanit',
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                            Text(
                                              '${priceFormat.format(model['netPrice']) + " บาท"}',
                                              style: TextStyle(
                                                fontSize: 23,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'คลัง : ${priceFormat.format(model['remaining'])}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'Kanit',
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    'ระบุลักษณะสินค้า',
                                    style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Expanded(
                                  //   child:
                                  ListView(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    children: [
                                      SizedBox(height: 15),
                                      buildWrap(setState, snapshot.data),
                                      SizedBox(height: 100),
                                    ],
                                  ),
                                  // )
                                ],
                              ),
                            ),
                            Positioned(
                              top: 15,
                              right: 15,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0 + MediaQuery.of(context).padding.bottom,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 15),
                                        InkWell(
                                          onTap: () => setState(() => {
                                                if (productQty > 1) productQty--
                                              }),
                                          child: Container(
                                            height: 30,
                                            width: 50,
                                            alignment: Alignment.topCenter,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                width: 1,
                                                color: productQty == 1
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              '-',
                                              style: TextStyle(
                                                fontFamily: 'Kanit',
                                                fontSize: 16,
                                                color: productQty == 1
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Container(
                                            height: 30,
                                            constraints:
                                                BoxConstraints(minWidth: 220),
                                            alignment: Alignment.topCenter,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(width: 1),
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              productQty.toString(),
                                              style: TextStyle(
                                                fontFamily: 'Kanit',
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        InkWell(
                                          onTap: () => setState(() {
                                            if (productQty < model['qty'])
                                              productQty++;
                                          }),
                                          child: Container(
                                            height: 30,
                                            width: 50,
                                            alignment: Alignment.topCenter,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                width: 1,
                                                color:
                                                    model['qty'] == productQty
                                                        ? Colors.grey
                                                        : Colors.black,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              '+',
                                              style: TextStyle(
                                                fontFamily: 'Kanit',
                                                fontSize: 16,
                                                color:
                                                    model['qty'] == productQty
                                                        ? Colors.grey
                                                        : Colors.black,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    InkWell(
                                      onTap: () async {
                                        if (model['qty'] <= 0) {
                                        } else {
                                          var allProduct = snapshot.data
                                              .firstWhere((c) =>
                                                  c['code'] ==
                                                  selectedInventory);
                                          allProduct['referenceShopCode'] =
                                              shopCode;
                                          allProduct['qty'] = productQty;
                                          allProduct['status'] = "N";
                                          allProduct['codegoods'] =
                                              widget.model['code'];
                                          if (type == 'cart') {
                                            // get amount item in cart.
                                            postDio(server + 'm/cart/count', {})
                                                .then((value) async {
                                              if (value != null)
                                                setState(() {
                                                  amountItemInCart =
                                                      value['count'];
                                                });
                                            });

                                            // check error create item in cart.
                                            bool status = await postDio(
                                                    server + 'm/cart/create',
                                                    allProduct)
                                                .then((value) => value != null);
                                            if (status)
                                              toastFail(context,
                                                  text: 'เพิ่มสินค้าสำเร็จ');
                                            else
                                              toastFail(context, text: 'fail');
                                            Navigator.pop(context);
                                          }
                                          // buy now button.
                                          else {
                                            allProduct['referenceShopCode'] =
                                                shopCode;
                                            allProduct['referenceShopName'] =
                                                shopName;

                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ConfirmOrderPage(
                                                  productList: [allProduct],
                                                  from: 'buyNow',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        color: model['qty'] <= 0
                                            ? Colors.grey
                                            : Theme.of(context).accentColor,
                                        alignment: Alignment.center,
                                        child: Text(
                                          model['qty'] <= 0
                                              ? 'สินค้าหมด'
                                              : type == 'cart'
                                                  ? 'เพิ่มไปยังรถเข็น'
                                                  : 'ซื้อสินค้า',
                                          style: TextStyle(
                                            fontFamily: 'Kanit',
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          // textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container();
                  } else {
                    return Container();
                  }
                });
          },
        );
      },
    );
  }

  Row buildCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 30,
          width: 50,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1),
            color: Colors.white,
          ),
          child: Text(
            '-',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 30,
            constraints: BoxConstraints(minWidth: 220),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1),
              color: Colors.white,
            ),
            child: Text(
              productQty.toString(),
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SizedBox(width: 15),
        InkWell(
          onTap: () => setState(() {
            productQty++;
          }),
          child: Container(
            height: 30,
            width: 50,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1),
              color: Colors.white,
            ),
            child: Text(
              '+',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }

  _buildReview() {
    return FutureBuilder(
      future: _futureComment,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) return Container();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'คะแนนสินค้า',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16,
                  ),
                ),
              ),
              ...snapshot.data
                  .map<Widget>(
                    (e) => Container(
                      margin: EdgeInsets.only(bottom: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: loadingImageNetwork(
                                    e['imageUrl'],
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 13),
                                Expanded(
                                  child: Text(
                                    e['createBy'],
                                    style: TextStyle(
                                        fontFamily: 'Kanit', fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          ratingBar(e['rating']),
                          SizedBox(height: 13),
                          Text(e['description']),
                          SizedBox(height: 13),
                          Container(height: 1, color: Colors.grey),
                        ],
                      ),
                    ),
                  )
                  .toList()
            ],
          );
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _readComment());
        } else {
          return Container();
        }
      },
    );
  }

  _readComment() {
    setState(() => _futureComment = postDio(
        server + 'm/goods/comment/read', {'code': widget.model['code']}));
  }

  buildWrap(StateSetter setState, model) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: model.map<Widget>(
        (e) {
          return buildAttribute(setState, e);
        },
      ).toList(),
    );
  }

  InkWell buildAttribute(StateSetter setState, e) {
    return InkWell(
      onTap: () => setState(() => selectedInventory = e['code']),
      child: selectedInventory == e['code']
          ? Container(
              height: e['title'].length > 50 ? null : 30,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).accentColor,
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).accentColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15,
                  ),
                  e['title'].length > 50
                      ? Expanded(
                          child: Text(
                            '${e['title']}',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          '${e['title']}',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            )
          : Container(
              height: e['title'].length > 50 ? null : 30,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1),
                color: Colors.white,
              ),
              child: Text(
                '${e['title']}',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
    );
    // return Container(
    //   height: 20,
    //   width: 30,
    //   color: Colors.red,
    // );
  }

  Widget ratingBar(param) {
    if (param == null) param = 0;
    var rating = double.parse(param.toString());
    if (rating == 0)
      return Container(
        child: Text(
          'ยังไม่มีรีวิวสำหรับสินค้าชิ้นนี้',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 12,
            color: Theme.of(context).accentColor,
          ),
        ),
      );
    const starFull = 'assets/images/star_full.png';
    const starHalf = 'assets/images/star_half_empty.png';
    const starEmpty = 'assets/images/star_empty.png';

    var strStar = new List<String>();

    for (int i = 1; i <= 5; i++) {
      double decimalRating = i - rating;

      if (decimalRating > 0 && decimalRating < 1) {
        strStar.add(starHalf);
      } else {
        if (i <= rating) {
          strStar.add(starFull);
        } else {
          strStar.add(starEmpty);
        }
      }
    }
    return Row(
      children:
          strStar.map((e) => Image.asset(e, height: 15, width: 15)).toList(),
    );
  }
}
