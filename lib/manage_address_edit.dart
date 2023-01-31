import 'package:flutter/material.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/pages/sell/address_category.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wereward/widget/stack_tap.dart';
import 'widget/header.dart';
import 'widget/text_form_field.dart';

class ManageAddressEditPage extends StatefulWidget {
  ManageAddressEditPage({Key key, this.code: ''}) : super(key: key);

  final String code;
  @override
  _ManageAddressEditPageState createState() => _ManageAddressEditPageState();
}

class _ManageAddressEditPageState extends State<ManageAddressEditPage> {
  List<dynamic> model;
  dynamic categoryModel = {'provinceTitle': ''};
  // Future<dynamic> _futureModel;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool isDefault = false;

  String selectedCodeLv1 = '';
  String selectedCodeLv2 = '';
  String selectedCodeLv3 = '';
  String selectedCodeLv4 = '';

  String titleCategoryLv1 = '';
  String titleCategoryLv2 = '';
  String titleCategoryLv3 = '';
  String titleCategoryLv4 = '';

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  final _formKey = GlobalKey<FormState>();
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
          title: 'จัดการที่อยู่',
        ),
        backgroundColor: Colors.white,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 15),
            children: _buildList(),
          ),
        ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(height: 10),
      Text('ที่อยู่ของฉัน',
          style: TextStyle(fontFamily: 'Kanit', fontSize: 15)),
      SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.only(left: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ตั้งเป็นค่าเริ่มต้น',
                style: TextStyle(fontFamily: 'Kanit', fontSize: 15)),
            Switch(
              value: isDefault,
              onChanged: (value) {
                setState(() {
                  isDefault = !isDefault;
                });
              },
              activeTrackColor: Theme.of(context).accentColor,
              activeColor: Color(0xFFFFFFFF),
            )
          ],
        ),
      ),
      Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text('ชื่อ-สกุล',
                style: TextStyle(fontFamily: 'Kanit', fontSize: 15)),
            textFormFieldAddress(
              nameController,
              'กรุณากรอกชื่อ นามสกุล',
              'กรุณากรอกชื่อ นามสกุล',
              true,
              false,
              false,
            ),
            SizedBox(height: 10),
            Text('หมายเลขโทรศัพท์',
                style: TextStyle(fontFamily: 'Kanit', fontSize: 15)),
            textFormFieldAddress(
              phoneController,
              'กรุณากรอกหมายเลขโทรศัพท์',
              'หมายเลขโทรศัพท์',
              true,
              false,
              false,
              textInputType: TextInputType.number,
              isPhone: true,
            ),
            SizedBox(height: 10),
            Text('รายละเอียดที่อยู่',
                style: TextStyle(fontFamily: 'Kanit', fontSize: 15)),
            SizedBox(height: 10),
            textFormFieldAddress(
              addressController,
              'กรุณากรอกรายละเอียดที่อยู่ เช่น บ้านเลขที่, หมู่, ซอย, ถนน,',
              'รายละเอียดที่อยู่',
              true,
              false,
              false,
            ),
          ],
        ),
      ),
      SizedBox(height: 10),
      _buildItemBtn(
        title: 'กรุณาเลือกจังหวัด',
        requried: true,
        icon: Icon(
          Icons.list,
          color: Colors.black,
        ),
        value: categoryModel['provinceTitle'],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressCategoryPage(model: categoryModel),
          ),
        ).then(
          (value) => setState(() => {
                if (value != null && value != '') categoryModel = value,
              }),
        ),
      ),
      SizedBox(height: 10),
      if (widget.code != '')
        InkWell(
          onTap: () => _buildDialog(),
          child: Container(
            height: 50,
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).backgroundColor,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                Text(
                  'ลบที่อยู่',
                  style: TextStyle(
                      fontFamily: 'Kanit', fontSize: 13, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      SizedBox(height: 40),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 35,
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(10.0),
            color: Color(0xFFED5643),
            child: MaterialButton(
              onPressed: () async {
                final form = _formKey.currentState;
                if (form.validate()) {
                  FocusScope.of(context).unfocus();
                  if (categoryModel['provinceCode'] == '' ||
                      categoryModel['provinceCode'] == null) {
                    return toastFail(context, text: 'กรุณาเลือกจังหวัด');
                  } else if (categoryModel['districtCode'] == '' ||
                      categoryModel['districtCode'] == null) {
                    return toastFail(context, text: 'กรุณาเลือกอำเภอ');
                  } else if (categoryModel['subDistrictCode'] == '' ||
                      categoryModel['subDistrictCode'] == null) {
                    return toastFail(context, text: 'กรุณาเลือกตำบล');
                  } else if (categoryModel['postCode'] == '' ||
                      categoryModel['postCode'] == null) {
                    return toastFail(context, text: 'กรุณาเลือกรหัสไปษณีย์');
                  } else {
                    form.save();
                    save();
                  }
                }
              },
              child: new Text(
                'ยืนยัน',
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
      SizedBox(height: 40),
    ];
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

  _buildDropDownButtonFormField(
    List<dynamic> dataDropDown,
    dynamic value, {
    String hint = '',
    Function validator,
    Function onChange,
    bool postCode = false,
  }) {
    return SizedBox(
      height: 60,
      child: DropdownButtonFormField(
        isDense: true,
        decoration: InputDecoration(
            errorStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              fontSize: 10.0,
            ),
            filled: true,
            fillColor: Theme.of(context).backgroundColor,
            // fillColor: Colors.red,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).backgroundColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).backgroundColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
              ),
            )),
        validator: (value) => validator(value),
        hint: Text(
          hint,
          style: TextStyle(
            fontSize: 13.00,
            fontFamily: 'Kanit',
          ),
        ),
        onChanged: (value) => {onChange(value)},
        value: value != '' ? value : null,
        items: dataDropDown.map<DropdownMenuItem<dynamic>>((dynamic item) {
          return DropdownMenuItem<dynamic>(
            child: new Text(
              item['title'] != null ? item['title'] : item['postCode'],
              style: TextStyle(
                fontSize: 13.00,
                fontFamily: 'Kanit',
                color: Color(
                  0xFFED5643,
                ),
              ),
            ),
            // value: postCode ? item['postCode'] : item['code'],
          );
        }).toList(),
      ),
    );
  }

  _buildDialog() async {
    return await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        return CustomAlertDialog1(
            contentPadding: EdgeInsets.all(20),
            content: Container(
              height: 80,
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ลบที่อยู่?',
                    style: TextStyle(
                        fontFamily: 'Kanit', fontSize: 15, color: Colors.grey),
                  ),
                  Container(
                      height: 1, width: double.infinity, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              'ไม่',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(height: 40, width: 1, color: Colors.grey),
                      Expanded(
                        child: InkWell(
                          onTap: () => delete(),
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            child: Text(
                              'ใช่',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
      },
    ).then((val) {
      setState(() {});
    });
  }

  save() async {
    String path = widget.code != '' ? 'update' : 'create';
    await postDio('${server}m/manageAddress/' + path, {
      "code": widget.code,
      'title': nameController.text,
      'address': addressController.text,
      'phone': phoneController.text,
      'provinceCode': categoryModel['provinceCode'],
      'districtCode': categoryModel['districtCode'],
      'subDistrictCode': categoryModel['subDistrictCode'],
      'postalCode': categoryModel['postCode'],
      'isDefault': isDefault,
    }).then((value) => {Navigator.pop(context, 'success')});
  }

  _callRead() async {
    var model = await postDio('${server}m/manageAddress/read', {
      "code": widget.code,
    });

    var data = model[0];
    nameController.text = data['title'];
    phoneController.text = data['phone'];
    addressController.text = data['address'];
    selectedCodeLv1 = data['provinceCode'];
    selectedCodeLv2 = data['districtCode'];
    selectedCodeLv3 = data['subDistrictCode'];
    selectedCodeLv4 = data['postalCode'];

    categoryModel = {
      'provinceTitle': data['provinceTitle'],
      'provinceCode': data['provinceCode'],
      'districtTitle': data['districtTitle'],
      'districtCode': data['districtCode'],
      'subDistrictTitle': data['subDistrictTitle'],
      'subDistrictCode': data['subDistrictCode'],
      'postCode': data['postalCode'],
    };

    setState(() {
      isDefault = data['isDefault'];
    });
  }

  delete() async {
    await postDio('${server}m/manageAddress/delete', {
      "code": widget.code,
    }).then((value) {
      Navigator.pop(context);
      Navigator.pop(context, 'success');
    });
  }
}
