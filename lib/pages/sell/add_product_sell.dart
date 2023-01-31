import 'package:flutter/material.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/image_picker.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/pages/sell/list_option_sell.dart';
import 'package:wereward/pages/sell/sell_category.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class AddProductSell extends StatefulWidget {
  const AddProductSell({Key key}) : super(key: key);

  @override
  _AddProductSellState createState() => _AddProductSellState();
}

class _AddProductSellState extends State<AddProductSell> {
  String image = '';
  dynamic listImage = [];
  TextEditingController textTitleController;
  TextEditingController textDetailController;

  dynamic categoryModel = {'title': ''};
  dynamic productOptionModel = [];
  bool showLoadingImage = false;

  double sizeFieldImage = 100;

  @override
  void initState() {
    textTitleController = new TextEditingController();
    textDetailController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textTitleController.dispose();
    textDetailController.dispose();
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
        backgroundColor: Theme.of(context).backgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: header2(context, title: 'เพิ่มสินค้า'),
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              _buildScreen(),
              showLoadingImage
                  ? Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.5),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  _buildScreen() {
    return Column(
      children: [
        Container(
          height: sizeFieldImage + 20,
          width: double.infinity,
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10),
            children: [
              ..._buildListImage(),
              _buildAddImage(),
            ],
          ),
        ),
        SizedBox(height: 8),
        _buildInput(
          'ชื่อสินค้า',
          textTitleController,
          hintText: 'เพิ่มชื่อสินค้า',
        ),
        SizedBox(height: 8),
        _buildInputDetail(
          'รายละเอียดสินค้า',
          textDetailController,
          hintText: 'รายละเอียดสินค้า',
          maxLength: 5000,
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
          ).then((value) =>
              setState(() => {if (value != null) categoryModel = value})),
        ),
        SizedBox(height: 3),
        _buildItemBtn(
          title: 'เพิ่มตัวเลือกสินค้า',
          requried: true,
          icon: Icon(
            Icons.local_fire_department_outlined,
            color: Colors.black,
          ),
          value: 'ตั้งค่า',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListOptionSell(model: productOptionModel),
            ),
          ).then((value) =>
              {if (value != null) setState(() => productOptionModel = value)}),
        ),
        Expanded(child: Container()),
        Container(
          height: 50 + MediaQuery.of(context).padding.bottom,
          color: Colors.white,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8 + MediaQuery.of(context).padding.bottom,
          ),
          child: StackTap(
            onTap: () => _create(),
            child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: Text(
                'บันทึก',
                style: TextStyle(
                    fontFamily: 'Kanit', fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
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
      onTap: () => {FocusScope.of(context).unfocus(), onTap()},
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

  Container _buildInput(
    String title,
    TextEditingController controller, {
    String hintText,
    int maxLength = 120,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: sizeFieldImage + 10),
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
          TextField(
            autofocus: false,
            style: new TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
            ),
            maxLength: maxLength,
            // maxLines: 1,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: new EdgeInsets.symmetric(horizontal: 10),
            ),
            controller: controller,
          )
        ],
      ),
    );
  }

  Container _buildInputDetail(
    String title,
    TextEditingController controller, {
    String hintText,
    int maxLength = 120,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: sizeFieldImage + 10),
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       title,
          //       style: TextStyle(
          //         fontFamily: 'Kanit',
          //         fontSize: 15,
          //       ),
          //     )
          //   ],
          // ),
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
                          .removeWhere((item) => item['id'] == e['id']),
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

  Widget _buildAddImage() {
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
              '+ เพิ่มรูปภาพ',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: Colors.orange,
              ),
            ),
          ),
        ),
        callback: (file) => _uploadImage(file),
      ),
    );
  }

  _uploadImage(file) {
    setState(() {
      showLoadingImage = true;
    });
    uploadImage(file).then((res) {
      var id = new DateTime.now().millisecondsSinceEpoch;
      setState(() => {
            listImage.add({'imageUrl': res, 'id': id}),
            showLoadingImage = false
          });
    }).catchError((err) {
      setState(() {
        showLoadingImage = false;
      });
      print(err);
    });
  }

  _create() async {
    bool status = await validateField();
    dynamic lvShop = await setLvShop();
    if (status) {
      return toastFail(context);
    } else {
      // productOptionModel.forEach((c) =>
      //     {c['price'] = int.parse(c['price']), c['qty'] = int.parse(c['qty'])});
      var data = {
        'imageUrl': listImage[0]['imageUrl'],
        'title': textTitleController.text,
        'description': textDetailController.text,
        'goodsInventory': productOptionModel,
        'galleries': listImage,
        'isActive': true,
        ...lvShop
      };

      var response = await postDio(server + 'm/goods/create', data);
      if (response != null) Navigator.pop(context, true);
    }
  }

  validateField() {
    bool result = false;
    if (textTitleController.text == '' ||
        textDetailController.text == '' ||
        categoryModel['code'] == null ||
        productOptionModel.length == 0 ||
        listImage.length == 0) result = true;

    return result;
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
