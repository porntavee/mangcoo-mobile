import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/image_picker.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/pages/sell/add_option.dart';
import 'package:wereward/pages/sell/sell_category.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/nav_animation.dart';
import 'package:wereward/widget/stack_tap.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  Future<dynamic> _futureModelGoodsInventory;
  TextEditingController textTitleController;
  TextEditingController textDescriptionController;
  String image = '';
  dynamic listImage = [];
  bool showLoading = false;
  double sizeFieldImage = 100;
  bool isActive = false;
  bool hasEdit = false;
  dynamic listGoodsInventory = [];
  dynamic categoryModel = {'title': ''};

  @override
  void initState() {
    textTitleController = new TextEditingController();
    textDescriptionController = new TextEditingController();
    super.initState();
    setData();
    readGallery();
    readGoodsInventory();
  }

  @override
  void dispose() {
    textTitleController.dispose();
    textDescriptionController.dispose();
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            iconSize: 27,
            splashRadius: 20,
            alignment: Alignment.center,
            onPressed: () => {
              // if (hasEdit) toastFail(context) else Navigator.pop(context),
              Navigator.pop(context)
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          title: Text(
            'สินค้า',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          actions: [
            StackTap(
              onTap: () => save(),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'บันทึก',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        // appBar: header2(context, title: 'สินค้า'),
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              _buildBody(context),
              if (showLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  ListView _buildBody(BuildContext context) {
    return ListView(
      children: [
        _buildSwitchStatus(),
        SizedBox(height: 8),
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'รูปภาพหลัก',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
          ),
        ),
        Row(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: _buildImageMain(),
            ),
            Expanded(child: Container(color: Colors.white, height: 120))
          ],
        ),
        SizedBox(height: 8),
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'รูปภาพ',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
          ),
        ),
        _buildGallery(),
        SizedBox(height: 8),
        _buildInput(
          'ชื่อสินค้า',
          textTitleController,
          hintText: 'ชื่อสินค้า',
        ),
        _buildInputDetail(
          'รายละเอียดสินค้า',
          textDescriptionController,
          hintText: 'รายละเอียดสินค้า',
        ),
        SizedBox(height: 8),
        _buildItemBtn(
          title: 'หมวดหมู่',
          requried: true,
          icon: Icon(
            Icons.list,
            color: Colors.black,
          ),
          value: categoryModel['title'],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellCategoryPage(model: categoryModel),
            ),
          ).then((value) => setState(() => {
                print(value),
                if (value != null) categoryModel = value,
              })),
        ),
        SizedBox(height: 8),
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'รายการสินค้า',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 16,
                ),
              ),
              StackTap(
                onTap: () =>
                    Navigator.push(context, scaleTransitionNav(AddOption()))
                        .then(
                  (value) {
                    if (value != null) {
                      dynamic res = value;
                      res['status'] = 'A';
                      setState(
                        () {
                          hasEdit = true;
                          listGoodsInventory = [res, ...listGoodsInventory];
                          print(listGoodsInventory);
                        },
                      );
                    }
                  },
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.redAccent[400]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'เพิ่มสินค้า',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: listGoodsInventory.length,
          separatorBuilder: (context, index) => Container(
            color: Colors.grey,
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 10),
          ),
          itemBuilder: (context, index) =>
              _buildGoodsInventory(listGoodsInventory[index]),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  StackTap _buildItemBtn(
      {String title,
      bool requried = false,
      String value = '',
      Icon icon,
      Function onTap}) {
    String req = requried ? ' *' : '';
    return StackTap(
      onTap: () => {
        FocusScope.of(context).unfocus(),
        onTap(),
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        color: Colors.white,
        child: Row(
          children: [
            icon,
            SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: req,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, size: 15),
          ],
        ),
      ),
    );
  }

  _buildGoodsInventory(model) {
    return StatefulBuilder(builder: (context, stateInventory) {
      return Stack(
        children: [
          StackTap(
            onTap: () => Navigator.push(
                    context, scaleTransitionNav(AddOption(model: model)))
                .then(
              (value) => setState(() => model = value),
            ),
            child: Stack(
              children: [
                Container(
                  height: 120,
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      loadingImageNetwork(
                        model['imageUrl'],
                        height: sizeFieldImage,
                        width: sizeFieldImage,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                model['title'],
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  model['remaining'] != null
                                      ? 'จำนวนคงเหลือ : ' +
                                          model['remaining'].toString()
                                      : 'จำนวนคงเหลือ : ' +
                                          model['qty'].toString(),
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 14,
                                  ),
                                ),
                                if (model['remaining'] != null &&
                                    model['plusQty'] != null &&
                                    model['plusQty'] > 0)
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                          color: Colors.green, width: 1),
                                    ),
                                    child: Text(
                                      'เพิ่ม ' +
                                          priceFormat.format(model['plusQty']),
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontFamily: 'Kanit',
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              'ราคา   : ' + priceFormat.format(model['price']),
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if (model['status'] == 'N')
                  Positioned.fill(
                      child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey.withOpacity(0.3),
                    child: Text(
                      'ซ่อนอยู่',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ))
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: model['id'] == null
                ? StackTap(
                    onTap: () => {
                      stateInventory(() {
                        if (model['status'] == 'N')
                          model['status'] = 'A';
                        else
                          model['status'] = 'N';
                      })
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: Colors.redAccent[400]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        model['status'] == 'A' ? 'ซ่อน' : 'แสดง',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'ใหม่',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  _buildImageMain() {
    return Stack(
      children: [
        ImageUploadPicker(
          child: Container(
            height: sizeFieldImage,
            width: sizeFieldImage,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.orange,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: image != ''
                ? loadingImageNetwork(image)
                : Center(
                    child: Text(
                      'เพิ่มรูปภาพหลัก',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                  ),
          ),
          callback: (file) => uploadImage(file).then((res) {
            var id = new DateTime.now().millisecondsSinceEpoch;
            setState(() => {image = res, showLoading = false});
          }).catchError((err) {
            setState(() {
              showLoading = false;
            });
            print(err);
          }),
        ),
        if (image != '')
          Positioned(
            top: 0,
            right: 0,
            child: StackTap(
              onTap: () => setState(() => image = ''),
              child: Container(
                height: 20,
                width: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                  color: Colors.red,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          )
      ],
    );
  }

  Container _buildSwitchStatus() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'แสดงสินค้า',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
          ),
          Switch(
            value: isActive,
            activeColor: Colors.red,
            inactiveTrackColor: Colors.grey,
            onChanged: (value) => setState(() => isActive = value),
          )
        ],
      ),
    );
  }

  Container _buildGallery() {
    return Container(
      height: sizeFieldImage + 20,
      width: double.infinity,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10),
        children: [
          ..._buildListImage(),
          _buildAddImage(uploadImage: (file) => _uploadImage(file)),
        ],
      ),
    );
  }

  Container _buildInput(
    String title,
    TextEditingController controller, {
    String hintText,
    int maxLength = 120,
    Function onChanged,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: 10),
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                ),
              )
            ],
          ),
          TextFormField(
            autofocus: false,
            style: new TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
            ),
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: new EdgeInsets.symmetric(horizontal: 10),
            ),
            controller: controller,
            onChanged: (value) => onChanged(value),
          )
        ],
      ),
    );
  }

  Container _buildInputDetail(
    String title,
    TextEditingController controller, {
    String hintText,
    int maxLength = 5000,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: 10),
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(height: 8),
          TextField(
            autofocus: false,
            style: new TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
            ),
            maxLength: maxLength,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding:
                  new EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            controller: controller,
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _buildListImage() {
    return listImage
        .map<Widget>(
          (e) => Padding(
            padding: EdgeInsets.only(top: 10, right: 10, bottom: 10),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: loadingImageNetwork(
                      e['imageUrl'],
                      height: sizeFieldImage - 2,
                      width: sizeFieldImage - 2,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: StackTap(
                    onTap: () => setState(
                      () => listImage
                          .removeWhere((item) => item['code'] == e['code']),
                    ),
                    child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                        color: Colors.red,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildAddImage(
      {Function uploadImage, String title = '+ เพิ่มรูปภาพ'}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ImageUploadPicker(
        child: Container(
          height: sizeFieldImage,
          width: sizeFieldImage,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.orange,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: Colors.orange,
              ),
            ),
          ),
        ),
        callback: (file) => uploadImage(file),
      ),
    );
  }

  _uploadImage(file) {
    setState(() {
      showLoading = true;
    });
    uploadImage(file).then((res) {
      var id = new DateTime.now().millisecondsSinceEpoch;
      setState(() => {
            listImage.add({'imageUrl': res, 'code': id}),
            showLoading = false
          });
    }).catchError((err) {
      setState(() {
        showLoading = false;
      });
      print(err);
    });
  }

  setData() async {
    image = widget.model['imageUrl'];
    textTitleController.text = widget.model['title'];
    textDescriptionController.text =
        parseHtmlString(widget.model['description']);
    isActive = widget.model['isActive'];
    await setCategory();
  }

  setCategory() {
    if (widget.model['lv1Shop'] != '') {
      categoryModel = {
        'code': widget.model['lv1Shop'],
        'title': widget.model['titleLv1Shop'],
        'category': 'lv1'
      };
    }
    if (widget.model['lv2Shop'] != '') {
      categoryModel = {
        'titleLv1': widget.model['titleLv1Shop'],
        'code': widget.model['lv2Shop'],
        'title': widget.model['titleLv2Shop'],
        'category': 'lv2',
        'lv1': widget.model['lv1Shop'],
        'isHighlight': true,
      };
    }
    if (widget.model['lv3Shop'] != '') {
      categoryModel = {
        'titleLv1': widget.model['titleLv1Shop'],
        'titleLv2': widget.model['titleLv2Shop'],
        'code': widget.model['lv3Shop'],
        'title': widget.model['titleLv3Shop'],
        'category': 'lv3',
        'lv1': widget.model['lv1Shop'],
        'lv2': widget.model['lv2Shop'],
        'isHighlight': true,
      };
    }
  }

  readGallery() async {
    var response = await postDio(
        server + 'm/goods/gallery/read', {'code': widget.model['code']});
    response.forEach((e) {
      setState(() {
        listImage.add({'imageUrl': e['imageUrl'], 'code': e['code']});
      });
    });
  }

  readGoodsInventory() async {
    var response = await postDio(server + 'm/goods/inventory/shop/read',
        {'reference': widget.model['code']});

    setState(() {
      listGoodsInventory = response;
    });
  }

  save() async {
    List<String> images = [];
    dynamic lvShop = await setLvShop();
    await listImage.forEach((e) => images.add(e['imageUrl']));
    await listGoodsInventory.forEach((e) => {
          if (e['plusQty'] != null && e['plusQty'] > 0)
            e['qty'] = e['plusQty']
          else
            e['qty'] = 0
        });

    var criteria = {
      'code': widget.model['code'],
      'imageUrl': image,
      'title': textTitleController.text,
      'description': textDescriptionController.text,
      'listGoodsInventory': listGoodsInventory,
      'galleries': images,
      'isActive': isActive,
      ...lvShop,
    };
    // print('listImage');
    // print(listImage);
    // print('textTitleController');
    // print(textTitleController.text);
    // print('listGoodsInventory');
    // print(listGoodsInventory);
    // print('lvShop');
    // print(lvShop);
    // print(widget.model['code']);
    // print(criteria);

    var response = await postDio(server + 'm/goods/shop/update', criteria);

    if (response != null) {
      toastFail(context, text: 'สำเร็จ');
      Navigator.pop(context);
    } else {
      toastFail(context);
    }
  }

  setLvShop() {
    var lv1Shop = '';
    var lv2Shop = '';
    var lv3Shop = '';
    if (categoryModel['category'] == 'lv1') lv1Shop = categoryModel['code'];
    if (categoryModel['category'] == 'lv2') {
      lv2Shop = categoryModel['code'];
      lv1Shop = categoryModel['lv1'];
    }
    if (categoryModel['category'] == 'lv3') {
      lv3Shop = categoryModel['code'];
      lv2Shop = categoryModel['lv2'];
      lv1Shop = categoryModel['lv1'];
    }

    return {'lv1Shop': lv1Shop, 'lv2Shop': lv2Shop, 'lv3Shop': lv3Shop};
  }
}
