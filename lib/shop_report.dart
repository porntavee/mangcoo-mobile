import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/component/material/image_picker.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class ShopReport extends StatefulWidget {
  const ShopReport({Key key, this.code}) : super(key: key);

  final String code;

  @override
  _ShopReportState createState() => _ShopReportState();
}

class _ShopReportState extends State<ShopReport> {
  TextEditingController textDescriptionController;
  bool showTitle = false;
  String title = '';
  double sizeFieldImage = 100;
  dynamic listImage = [];
  bool showLoading = false;

  @override
  void initState() {
    textDescriptionController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header2(context, title: 'รายงานผู้ใช้'),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            _buildBody(context),
            _buildBtn(),
            if (showLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.grey.withOpacity(0.3),
                ),
              )
          ],
        ),
      ),
    );
  }

  _buildBtn() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 50 + MediaQuery.of(context).padding.bottom,
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: 8 + MediaQuery.of(context).padding.bottom,
        ),
        color: Colors.white,
        child: StackTap(
          onTap: () => save(),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'เพิ่ม',
              style: TextStyle(
                  fontFamily: 'Kanit', fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  ListView _buildBody(BuildContext context) {
    return ListView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 66),
      children: [
        GestureDetector(
          onTap: () => setState(() {
            showTitle = !showTitle;
          }),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'เลือกเหตุผล',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14,
                  ),
                ),
                Icon(showTitle
                    ? Icons.arrow_drop_up_sharp
                    : Icons.arrow_drop_down_sharp)
              ],
            ),
          ),
        ),
        if (showTitle) ..._buildListSubject(),
        SizedBox(height: 11),
        _buildInputDetail(
          textDescriptionController,
          hintText: 'เหตุผลในการรายงาน',
        ),
        SizedBox(height: 11),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Text(
            'รูปภาพที่รองรับ',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
            ),
          ),
        ),
        _buildGallery(),
      ],
    );
  }

  List<Widget> _buildListSubject() {
    return ['สินค้าหมด', 'สินค้าปลอม', 'หลอกลวง', 'เนื้อหาไม่เหมาะสม', 'อื่นๆ']
        .map<Widget>(
          (e) => GestureDetector(
            onTap: () {
              setState(() {
                title = e;
              });
            },
            child: Container(
              padding: EdgeInsets.only(left: 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e,
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 14,
                        ),
                      ),
                      if (title == e)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.check, color: Colors.red),
                          ),
                        ),
                      SizedBox(width: 10)
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    color: Colors.grey,
                    height: 0.5,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Container _buildInputDetail(
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

  save() async {
    var status = await validate();
    var images = [];
    if (status) return toastFail(context, text: 'กรุณากรอกข้อมูลให้ครบ');

    await listImage.forEach((e) => images.add(e['imageUrl']));
    var response = await postDio(server + 'm/shopreport/create', {
      'title': title,
      'referenceShopCode': widget.code,
      'description': textDescriptionController.text,
      'galleries': images,
    });

    if (response != null) {
      toastFail(context, text: 'สำเร็จ');
      Navigator.pop(context);
    } else {
      toastFail(context);
    }
  }

  validate() {
    if (title == '') return true;
    if (textDescriptionController.text == '') return true;
    return false;
  }
}
