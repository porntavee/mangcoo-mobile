import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wereward/component/material/loading_tween.dart';
import 'package:wereward/manage_address_edit.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReceiptAndTaxInvoicePage extends StatefulWidget {
  @override
  _ReceiptAndTaxInvoicePageState createState() =>
      _ReceiptAndTaxInvoicePageState();
}

class _ReceiptAndTaxInvoicePageState extends State<ReceiptAndTaxInvoicePage> {
  List<dynamic> model;
  Future<dynamic> _futureModel;
  PageController pageController;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  var tempData = List<dynamic>();
  int currentTabIndex = 0;

  final _formKey = GlobalKey<FormState>(); // <-
  TextEditingController nameTextEditingController;
  TextEditingController branchTextEditingController;
  TextEditingController numberBranchTextEditingController;
  TextEditingController taxIdTextEditingController;
  TextEditingController addressTextEditingController;
  TextEditingController postCodeTextEditingController;
  TextEditingController emailTextEditingController;

  @override
  void initState() {
    pageController = new PageController(initialPage: currentTabIndex);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            _buildHead(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildList(),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Container(
                height: 35,
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFFED5643),
                  child: MaterialButton(
                    onPressed: () {
                      save();
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
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  _buildHead() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      height: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 85,
            padding: EdgeInsets.only(
              bottom: 10,
              top: MediaQuery.of(context).padding.top,
              left: 15,
              right: 15,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: Text(
                    'ใบเสร็จรับเงิน / ใบกำกับภาษี',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      color: Colors.white,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: 75,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  'รายละเอียด',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildButtonHeader('ใบเสร็จรับเงิน', 0),
                    SizedBox(width: 10),
                    buildButtonHeader('ใบกำกับภาษีเต็มรูปแบบ', 1)
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  buildButtonHeader(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => {
          setState(() => currentTabIndex = index),
        },
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: currentTabIndex == index
                ? Color(0xFFED5643)
                : Colors.transparent,
            border: Border.all(
              width: 1,
              color:
                  currentTabIndex == index ? Color(0xFFED5643) : Colors.black,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: currentTabIndex == index ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(height: 10),
      textInputTax(nameTextEditingController, labelText: 'ชื่อ - นามสกุล'),
      SizedBox(height: 3),
      textInputTax(addressTextEditingController,
          labelText: 'ที่อยู่', maxLines: 3),
      SizedBox(height: 3),
      textInputTax(postCodeTextEditingController, labelText: 'รหัสไปรษณีย์'),
      SizedBox(height: 3),
      textInputTax(emailTextEditingController, labelText: 'อีเมล'),
      if (currentTabIndex == 1) ...buildListTaxInvoice(),
    ];
  }

  buildListTaxInvoice() {
    return <Widget>[
      SizedBox(height: 3),
      textInputTax(branchTextEditingController, labelText: 'ชื่อสาขา'),
      SizedBox(height: 3),
      textInputTax(numberBranchTextEditingController,
          labelText: 'เลขที่ของสาขา'),
      SizedBox(height: 3),
      textInputTax(taxIdTextEditingController,
          labelText: 'เลขประจำตัวผู้เสียภาษีอากร'),
    ];
  }

  buildInput() {
    return Container(
      height: 40,
      color: Colors.white,
    );
  }

  textInputTax(
    TextEditingController controller, {
    String labelText,
    Function validator,
    int maxLines = 1,
    int maxLength,
    bool enabled,
  }) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        maxLines: maxLines,
        maxLength: maxLength,
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
          fontSize: 13.00,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          hintText: '',
          labelText: labelText,
          labelStyle: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
          errorStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
            fontSize: 13.0,
          ),
        ),
        validator: (value) => validator(),
        controller: controller,
        enabled: enabled,
      ),
    );
  }

  validate(String type) {
    if (type == 'password') {
      Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,}$';
      RegExp regex = new RegExp(pattern);
      if (model.length < 6) {
        return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
      }
    }
    if (type == 'email') {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      // if (!regex.hasMatch(model)) {
      //   return 'กรุณากรอกรูปแบบอีเมลให้ถูกต้อง.';
      // }
    }
  }

  save() {
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }
}
