import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/image_picker.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class AddOption extends StatefulWidget {
  const AddOption({Key key, this.model: const {'id': ''}}) : super(key: key);

  final dynamic model;

  @override
  _AddOptionState createState() => _AddOptionState();
}

class _AddOptionState extends State<AddOption> {
  TextEditingController textTitleController;
  TextEditingController textPriceController;
  TextEditingController textQtyController;
  TextEditingController textRemainingController;
  TextEditingController textPlusQtyController;

  String image = '';
  dynamic model = {'id': ''};
  bool showLoadingImage = false;

  @override
  void initState() {
    textTitleController = new TextEditingController();
    textPriceController = new TextEditingController();
    textQtyController = new TextEditingController();
    textRemainingController = new TextEditingController();
    textPlusQtyController = new TextEditingController(text: '0');

    print(widget.model);
    if (widget.model['id'] != '') {
      model = widget.model;
      image = model['imageUrl'];
      textTitleController.text = model['title'];
      textPriceController.text = model['price'].toString();
      textQtyController.text = model['qty'].toString();
      textRemainingController.text = model['remaining'].toString();
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textTitleController.dispose();
    textPriceController.dispose();
    textQtyController.dispose();
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: header2(context, title: ''),
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Column(
                children: [
                  _buildImage(),
                  _buildInput(
                    'ลักษณะสินค้า',
                    textTitleController,
                    enabled: model['code'] == '' || model['code'] == null
                        ? true
                        : false,
                    hintText: 'ลักษณะ',
                    maxLength: 120,
                  ),
                  _buildInput(
                    'ราคา',
                    textPriceController,
                    enabled: model['code'] == '' || model['code'] == null
                        ? true
                        : false,
                    keyboardType: TextInputType.number,
                    hintText: 'จำนวน',
                  ),
                  _buildInput(
                    model['code'] == '' || model['code'] == null
                        ? 'จำนวน'
                        : 'จำนวนคงเหลือ',
                    model['code'] == '' || model['code'] == null
                        ? textQtyController
                        : textRemainingController,
                    enabled: model['code'] == '' || model['code'] == null
                        ? true
                        : false,
                    keyboardType: TextInputType.number,
                    hintText: 'จำนวน',
                  ),
                  SizedBox(height: 20),
                  if (model['code'] != '' && model['code'] != null)
                    _buildInput(
                      'เพิ่มสินค้า',
                      textPlusQtyController,
                      keyboardType: TextInputType.number,
                      hintText: 'จำนวน',
                    ),
                  // ..._buildAddQty()
                ],
              ),
              _buildSaveButton(context),
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

  List<Widget> _buildAddQty() {
    return <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'เพิ่มสินค้า',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.red),
        child: Text('50'),
      )
    ];
  }

  Positioned _buildSaveButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: StackTap(
        onTap: () async {
          var id = await getRandomString(10);
          setState(() {
            if (model['id'] != '') {
              model['imageUrl'] = image;
              model['title'] = textTitleController.text;
              model['price'] = int.parse(textPriceController.text);
              model['qty'] = int.parse(textQtyController.text);
              model['plusQty'] = int.parse(textPlusQtyController.text);
            } else
              model = {
                'id': id,
                'imageUrl': image,
                'title': textTitleController.text,
                'price': int.parse(textPriceController.text),
                'qty': int.parse(textQtyController.text),
              };
          });
          if (model['imageUrl'] == '' ||
              model['title'] == '' ||
              model['price'] == '' ||
              model['qty'] == '')
            return toastFail(context, text: 'กรุณากรอกข้อมูลให้ครบ');
          else
            Navigator.pop(context, model);
        },
        child: Container(
          height: 50 + MediaQuery.of(context).padding.bottom,
          width: double.infinity,
          color: Colors.red,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'บันทึก',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Container _buildInput(
    String title,
    TextEditingController controller, {
    bool enabled = true,
    String hintText,
    int maxLength,
    TextInputType keyboardType,
  }) {
    return Container(
      height: 100,
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
            enabled: enabled,
            keyboardType: keyboardType,
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
            inputFormatters: keyboardType == TextInputType.number
                ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                : null, // Only numbers can be entered
            controller: controller,
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ImageUploadPicker(
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
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
      setState(() {
        setState(() => image = res);
        showLoadingImage = false;
      });
    }).catchError((err) {
      setState(() {
        showLoadingImage = false;
      });
      print(err);
    });
  }
}
