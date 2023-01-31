import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wereward/component/header.dart';
import 'package:wereward/shared/api_provider.dart';

class ReporterFormPage extends StatefulWidget {
  ReporterFormPage({
    Key key,
    this.title,
    this.code,
    this.imageUrl,
  }) : super(key: key);

  final String title;
  final String code;
  final String imageUrl;

  @override
  _ReporterFormPageState createState() => _ReporterFormPageState();
}

class _ReporterFormPageState extends State<ReporterFormPage> {
  final storage = new FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtPrefixName = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtUsername = TextEditingController();
  final txtIdCard = TextEditingController();
  final txtLineID = TextEditingController();
  final txtOfficerCode = TextEditingController();
  final txtAddress = TextEditingController();
  final txtMoo = TextEditingController();
  final txtSoi = TextEditingController();
  final txtRoad = TextEditingController();

  final txtTitle = TextEditingController();
  final txtDescription = TextEditingController();
  double latitude = 13.772624948693206;
  double longitude = 100.5092097764907;

  String currentLocation;
  bool isShowMap = true;

  List<dynamic> _itemImage = [];
  List<Marker> markers = [];
  List<Marker> markerSelect = [];

  addMarker(latLng, newSetState) {
    setState(() {
      latitude = latLng.latitude;
      longitude = latLng.longitude;
    });
    newSetState(() {
      markers.clear();

      markers.add(Marker(markerId: MarkerId('New'), position: latLng));
    });
  }

  selectMarker() async {
    setState(() {
      markerSelect = markers;
      isShowMap = true;
    });
  }

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  Future<dynamic> futureModel;

  ScrollController scrollController = new ScrollController();

  XFile _image;

  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    txtPhone.dispose();
    txtDate.dispose();
    txtTitle.dispose();
    txtDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getLocation();
    futureModel = _getCurrentPosition();

    scrollController = ScrollController();

    super.initState();
  }

  Future<dynamic> _getCurrentPosition() async {
    //  var res = await getCurrentPosition();
    // setState(() {
    //   latitude = res.latitude;
    //   longitude = res.longitude;
    //   markers.add(
    //     Marker(
    //       markerId: MarkerId('New'),
    //       position: LatLng(res.latitude, res.longitude),
    //     ),
    //   );
    // });
  }

  void _getLocation() async {
    //  Position position = await getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.best,
    // );

    // final coordinates = new Coordinates(position.latitude, position.longitude);

    // var address = await Geocoder.google(
    //   'AIzaSyD-pkE26l2sWEU_CrbDz6b2myMe5Ab7jJo',
    //   language: 'th',
    // ).findAddressesFromCoordinates(coordinates);

    // setState(() {
    //   currentLocation = address.first.adminArea;
    // });
  }

  Future<dynamic> submitReporter() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value);

    var profileCode = await storage.read(key: 'profileCode10');
    var data = {
      "title": txtTitle.text,
      "enTitle": txtTitle.text,
      "description": txtDescription.text,
      "enDescription": txtDescription.text,
      "category": widget.code,
      "latitude": latitude.toString() ?? '',
      "longitude": longitude.toString() ?? '',
      "createBy": user['username'] ?? '',
      "firstName": user['firstName'] ?? '',
      "lastName": user['lastName'] ?? '',
      "imageUrlCreateBy": user['imageUrl'] ?? '',
      "imageUrl": widget.imageUrl ?? '',
      "gallery": _itemImage,
      "province": currentLocation ?? '',
      "lv0": user['lv0'],
      "lv1": user['lv1'],
      "lv2": user['lv2'],
      "lv3": user['lv3'],
      "lv4": user['lv4'],
      "countUnit": user['countUnit'],
      "language": 'th',
      "platform": Platform.operatingSystem.toString(),
      "profileCode": profileCode
    };

    final result = await postObjectData('m/v2/Reporter/create', data);

    if (result['status'] == 'S') {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: new Text(
                'บันทึกข้อมูลเรียบร้อยแล้ว',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(" "),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF005C9E),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    goBack();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: new Text(
                'บันทึกข้อมูลไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: new Text(
                result['message'],
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF005C9E),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.of(context).pop();
                    // goBack();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0),
            ),
            Text(
              '* หัวข้อ',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5.0),
            TextFormField(
              style: TextStyle(
                color: Color(0xFF000070),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
                fontSize: 15.00,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFC5DAFC),
                contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                hintText: 'รายละเอียด',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                errorStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Kanit',
                  fontSize: 10.0,
                ),
              ),
              validator: (model) {
                if (model.isEmpty) {
                  return 'กรุณากรอกรายละเอียด.';
                }
              },
              controller: txtTitle,
              enabled: true,
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: null,
            ),
            SizedBox(height: 15.0),
            Text(
              '* รายละเอียด',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
            TextFormField(
              style: TextStyle(
                color: Color(0xFF000070),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
                fontSize: 15.00,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFC5DAFC),
                contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                hintText: 'รายละเอียด',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                errorStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Kanit',
                  fontSize: 10.0,
                ),
              ),
              validator: (model) {
                if (model.isEmpty) {
                  return 'กรุณากรอกรายละเอียด.';
                }
              },
              controller: txtDescription,
              enabled: true,
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: null,
            ),
            SizedBox(height: 15.0),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เพิ่มรูปภาพ',
                        style: TextStyle(
                          fontSize: 18.00,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'สามารถอัพโหลดรูปภาพได้เกิน 10 รูป',
                        style: TextStyle(
                          fontSize: 12.00,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF7514),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            _showPickerImage(context);
                          },
                          padding: EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/images/picture.png',
                            height: 20.0,
                            width: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_itemImage.length > 0)
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                  ),
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _itemImage.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(top: 5.0),
                      width: 400,
                      child: MaterialButton(
                          onPressed: () {
                            dialogDeleteImage(
                                _itemImage[index]['id'].toString());
                          },
                          child: loadingImageNetwork(
                            _itemImage[index]['imageUrl'],
                            width: 1000,
                            fit: BoxFit.cover,
                          )
                          // Image.network(
                          //   _itemImage[index]['imageUrl'],
                          //   width: 1000,
                          //   fit: BoxFit.cover,
                          // ),
                          // ),
                          ),
                    );
                  },
                ),
              ),
            SizedBox(height: 15.0),
            Text(
              'ตำแหน่ง',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (markerSelect.length > 0 && isShowMap)
              Container(
                height: 250.0,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      latitude != null ? latitude : 13.772624948693206,
                      longitude != null ? longitude : 100.5092097764907,
                    ),
                    zoom: 14,
                  ),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(
                      () => new EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                  markers: markerSelect.toSet(),
                ),
              ),
            Container(
              margin: EdgeInsets.only(top: 10.0),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              // padding: EdgeInsets.symmetric(horizontal: 80.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: Color(0xFFFF7514),
                    ),
                  ),
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    onPressed: () {
                      setState(() {
                        isShowMap = false;
                      });

                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        barrierColor: Colors.black45,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (
                          BuildContext context,
                          Animation animation,
                          Animation secondaryAnimation,
                        ) {
                          return StatefulBuilder(
                            builder: (context, newSetState) {
                              return Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  padding: EdgeInsets.all(0),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.9,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                              latitude != null
                                                  ? latitude
                                                  : 13.772624948693206,
                                              longitude != null
                                                  ? longitude
                                                  : 100.5092097764907,
                                            ),
                                            zoom: 14,
                                          ),
                                          markers: markers.toSet(),
                                          onTap: (newLatLng) {
                                            addMarker(newLatLng, newSetState);
                                          },
                                        ),
                                      ),
                                      RaisedButton(
                                        onPressed: () {
                                          selectMarker();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'ตกลง',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'Kanit',
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        color: const Color(0xFFFF7514),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      'ตำแหน่ง Google Map',
                      style: TextStyle(
                        color: Color(0xFFFF7514),
                        fontFamily: 'Kanit',
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(5.0),
                  color: Color(0xFFFF7514),
                  child: MaterialButton(
                    height: 40,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        form.save();
                        submitReporter();
                      }
                    },
                    child: new Text(
                      'บันทึกข้อมูล',
                      style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  dialogDeleteImage(String code) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(
          'ต้องการลบรูปภาพ ใช่ไหม',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        content: new Text(''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "ยกเลิก",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kanit',
                color: Color(0xFF005C9E),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "ลบ",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kanit',
                color: Color(0xFFFF7514),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              deleteImage(code);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  deleteImage(String code) async {
    setState(() {
      _itemImage.removeWhere((c) => c['id'].toString() == code.toString());
    });
  }

  _imgFromCamera() async {
    XFile image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    setState(() {
      _image = image;
    });
    _upload();
  }

  _imgFromGallery() async {
    XFile image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    setState(() {
      _image = image;
    });
    _upload();
  }

  void _upload() async {
    if (_image == null) return;

    Random random = new Random();
    uploadImage(_image).then((res) {
      setState(() {
        _itemImage.add({'imageUrl': res, 'id': random.nextInt(100)});
      });
      // setState(() {
      //   _imageUrl = res;
      // });
    }).catchError((err) {
      print(err);
    });
  }

  void _showPickerImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.photo_library),
                  title: new Text(
                    'อัลบั้มรูปภาพ',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    'กล้องถ่ายรูป',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void goBack() async {
    Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ReporterListCategory(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<dynamic>(
    // future: futureModel,
    // builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //   if (snapshot.connectionState == ConnectionState.waiting) {
    //     return Center(
    //       child: Image.asset(
    //         "assets/background/login.png",
    //         fit: BoxFit.cover,
    //       ),
    //     );
    //   } else {
    //     if (snapshot.hasError)
    //       return Center(child: Text('Error: ${snapshot.error}'));
    //     else
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
        appBar: header(context, goBack, title: widget.title),
        body: Container(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Container(
                color: Colors.white,
                child: contentCard(),
              ),
            ],
          ),
        ),
      ),
    );
    // }
//       },
//     );
  }
}
