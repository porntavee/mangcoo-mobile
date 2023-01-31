import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:wereward/home_mart.dart';
import 'package:wereward/shared/google.dart';
import 'package:wereward/shared/line.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:wereward/models/user.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

import '../home_mart.dart';

const appName = 'Mangcoo';
const versionName = '1.1.7';
const versionNumber = 117;

// flutter build apk --build-name=1.0.0 --build-number=1
// flutter build appbundle --no-shrink

const server = 'http://mangcoo.com/api/';
const serverUpload = 'http://mangcoo.com/media/upload';
const serverReport = 'http://122.155.223.63/td-we-mart-report/';
const serverOTP = 'https://portal-otp.smsmkt.com/api/';

const registerApi = server + 'm/register/';
const newsApi = server + 'm/news/';
const partnerApi = server + 'm/partner/';
const partnerCategoryApi = server + 'm/partner/category/';
const newsGalleryApi = server + 'm/news/gallery/read';
const pollApi = server + 'm/poll/';
const poiApi = server + 'm/poi/';
const poiGalleryApi = server + 'm/poi/gallery/read';
const faqApi = server + 'm/faq/';
const knowledgeApi = server + 'm/knowledge/';
const cooperativeApi = server + 'm/cooperativeForm/';
const contactApi = server + 'm/contact/';
const bannerApi = server + 'm/banner/';
const bannerGalleryApi = server + 'm/banner/gallery/read';
const privilegeApi = server + "m/privilege/";
const menuApi = server + "m/menu/";
const aboutUsApi = server + "m/aboutus/";
const welfareApi = server + 'm/welfare/';
const welfareGalleryApi = server + 'm/welfare/gallery/read';
const eventCalendarApi = server + 'm/eventCalendar/';
const eventCalendarCategoryApi = server + 'm/eventCalendar/category/';
const eventCalendarCommentApi = server + 'm/eventCalendar/comment/';
const eventCalendarGalleryApi = server + 'm/eventCalendar/gallery/read';
const pollGalleryApi = server + 'm/poll/gallery/read';
const reporterApi = server + 'm/v2/reporter/';
const reporterGalleryApi = server + 'm/Reporter/gallery/';
const fundApi = server + 'm/fund/';
const fundGalleryApi = server + 'm/fund/gallery/read';
const warningApi = server + 'm/warning/';
const warningGalleryApi = server + 'm/warning/gallery/read';
const privilegeGalleryApi = server + 'm/privilege/gallery/read';
const productCategoryApi = server + 'm/product/category/';
const promotionApi = server + 'm/promotion/';
const promotionCategoryApi = server + 'm/promotion/category/';
const promotionCommentApi = server + 'm/promotion/comment/';
const promotionGalleryApi = server + 'm/promotion/gallery/read';

//banner
const mainBannerApi = server + 'm/Banner/main/';
const contactBannerApi = server + 'm/Banner/contact/';
const reporterBannerApi = server + 'm/Banner/reporter/';
const privilegeBannerApi = server + 'm/Banner/main/';
const promotionBannerApi = server + 'm/Banner/main/';
const newsBannerApi = server + 'm/Banner/main/';

//rotation
const rotationApi = server + 'rotation/';
const mainRotationApi = server + 'm/Rotation/main/';
const rotationGalleryApi = server + 'm/rotation/gallery/read';
const rotationWarningApi = server + 'm/rotation/warning/read';
const rotationWelfareApi = server + 'm/rotation/welfare/read';
const rotationNewsApi = server + 'm/rotation/news/read';
const rotationPoiApi = server + 'm/rotation/poi/read';
const rotationPrivilegeApi = server + 'm/rotation/privilege/read';
const rotationNotificationApi = server + 'm/rotation/notification/read';
const rotationEvantCalendarApi = server + 'm/rotation/event/read';
const rotationReporterApi = server + 'm/rotation/reporter/read';

//mainPopup
const mainPopupHomeApi = server + 'm/MainPopup/';
const forceAdsApi = server + 'm/ForceAds/';

const couponCategoryApi = server + 'm/coupon/category/';

// comment
const newsCommentApi = server + 'm/news/comment/';
const welfareCommentApi = server + 'm/welfare/comment/';
const poiCommentApi = server + 'm/poi/comment/';
const fundCommentApi = server + 'm/fund/comment/';
const warningCommentApi = server + 'm/warning/comment/';

//category
const knowledgeCategoryApi = server + 'm/knowledge/category/';
const cooperativeCategoryApi = server + 'm/cooperativeForm/category/';
const newsCategoryApi = server + 'm/news/category/';
const privilegeCategoryApi = server + 'm/privilege/category/';
const contactCategoryApi = server + 'm/contact/category/';
const welfareCategoryApi = server + 'm/welfare/category/';
const fundCategoryApi = server + 'm/fund/category/';
const pollCategoryApi = server + 'm/poll/category/';
const poiCategoryApi = server + 'm/poi/category/';
const reporterCategoryApi = server + 'm/v2/reporter/category/';
const warningCategoryApi = server + 'm/warning/category/';

const splashApi = server + 'm/splash/read';
const versionReadApi = '${server}m/v2/version/read';
const privilegeSpecialReadApi =
    'http://122.155.223.63/td-we-mart-api/m/privilege/ssp/read';
const privilegeSpecialCategoryReadApi =
    'http://122.155.223.63/td-we-mart-api/m/privilege/category/read';

Future<dynamic> postCategory(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  var value = await storage.read(key: 'dataUserLoginDDPM');
  var dataUser = json.decode(value);
  List<dynamic> dataOrganization = [];
  dataOrganization =
      dataUser['countUnit'] != '' ? json.decode(dataUser['countUnit']) : [];

  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
    "category": criteria['category'] != null ? criteria['category'] : '',
    "keySearch": criteria['keySearch'] != null ? criteria['keySearch'] : '',
    "username": criteria['username'] != null ? criteria['username'] : '',
    "isHighlight":
        criteria['isHighlight'] != null ? criteria['isHighlight'] : false,
    "language": criteria['language'] != null ? criteria['language'] : 'th',
    "organization": dataOrganization != null ? dataOrganization : [],
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];
  list = [...list, ...data['objectData']];

  return Future.value(list);
}

Future<dynamic> post(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  var value = await storage.read(key: 'dataUserLoginDDPM');
  var dataUser = json.decode(value);
  List<dynamic> dataOrganization = [];
  dataOrganization =
      dataUser['countUnit'] != '' ? json.decode(dataUser['countUnit']) : [];

  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
    "category": criteria['category'] != null ? criteria['category'] : '',
    "keySearch": criteria['keySearch'] != null ? criteria['keySearch'] : '',
    "username": criteria['username'] != null ? criteria['username'] : '',
    "firstName": criteria['firstName'] != null ? criteria['firstName'] : '',
    "lastName": criteria['lastName'] != null ? criteria['lastName'] : '',
    "title": criteria['title'] != null ? criteria['title'] : '',
    "answer": criteria['answer'] != null ? criteria['answer'] : '',
    "isHighlight":
        criteria['isHighlight'] != null ? criteria['isHighlight'] : false,
    "createBy": criteria['createBy'] != null ? criteria['createBy'] : '',
    "isPublic": criteria['isPublic'] != null ? criteria['isPublic'] : false,
    "language": criteria['language'] != null ? criteria['language'] : 'th',
    "organization": dataOrganization != null ? dataOrganization : [],
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);
  return Future.value(data['objectData']);
}

Future<dynamic> postAny(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "category": criteria['category'] != null ? criteria['category'] : '',
    "username": criteria['username'] != null ? criteria['username'] : '',
    "password": criteria['password'] != null ? criteria['password'] : '',
    "createBy": criteria['createBy'] != null ? criteria['createBy'] : '',
    "profileCode":
        criteria['profileCode'] != null ? criteria['profileCode'] : '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] != null
        ? criteria['imageUrlCreateBy']
        : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);

  return Future.value(data['status']);
}

Future<dynamic> postAnyObj(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "createBy": criteria['createBy'] != null ? criteria['createBy'] : '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] != null
        ? criteria['imageUrlCreateBy']
        : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);

  return Future.value(data);
}

Future<dynamic> postLogin(String url, dynamic criteria) async {
  var body = json.encode({
    "category": criteria['category'] != null ? criteria['category'] : '',
    "password": criteria['password'] != null ? criteria['password'] : '',
    "username": criteria['username'] != null ? criteria['username'] : '',
    "email": criteria['email'] != null ? criteria['email'] : '',
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);

  return Future.value(data['objectData']);
}

Future<dynamic> postObjectData(String url, dynamic criteria) async {
  var body = json.encode(criteria);

  var response = await http.post(Uri.parse(server + url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  // print('-----response.statusCode-----${response.statusCode}');
  if (response.statusCode == 200) {
    // print('-----response.body-----${response.body}');
    var data = json.decode(response.body);
    return {
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData']
    };
    // Future.value(data['objectData']);
  } else {
    return {"status": "F"};
  }
}

Future<dynamic> postConfigShare() async {
  var body = json.encode({});

  var response = await http.post(
      Uri.parse(server + 'configulation/shared/read'),
      body: body,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      });
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      // Future.value(data['objectData']);
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData']
    };
  } else {
    return {"status": "F"};
  }
}

Future<LoginRegister> postLoginRegister(String url, dynamic criteria) async {
  var body = json.encode(criteria);

  var response = await http.post(Uri.parse(server + url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  if (response.statusCode == 200) {
    var userMap = jsonDecode(response.body);

    var user = new LoginRegister.fromJson(userMap);
    return Future.value(user);
  } else {
    // ignore: null_argument_to_non_null_type
    return Future.value();
  }
}

//upload with dio
Future<String> uploadImage(XFile file) async {
  Dio dio = new Dio();

  String fileName = file.path.split('/').last;
  FormData formData = FormData.fromMap({
    "ImageCaption": "flutter",
    "Image": await MultipartFile.fromFile(file.path, filename: fileName),
  });

  var response = await dio.post(serverUpload, data: formData);

  return response.data['imageUrl'];
}

//upload with http
upload(File file) async {
  var uri = Uri.parse(serverUpload);
  var request = http.MultipartRequest('POST', uri)
    ..fields['ImageCaption'] = 'flutter2'
    ..files.add(await http.MultipartFile.fromPath('Image', file.path,
        contentType: MediaType('application', 'x-tar')));
  var response = await request.send();
  if (response.statusCode == 200) {
    return response;
  }
}

createStorageApp({dynamic model, String category}) {
  final storage = new FlutterSecureStorage();

  storage.write(key: 'profileCategory', value: category);

  storage.write(
    key: 'profileCode10',
    value: model['code'],
  );

  storage.write(
    key: 'customerID',
    value: model['customerID'],
  );

  storage.write(
    key: 'profileImageUrl',
    value: model['imageUrl'],
  );

  storage.write(
    key: 'profileFirstName',
    value: model['firstName'],
  );

  storage.write(
    key: 'profilePhone',
    value: model['phone'],
  );

  storage.write(
    key: 'profileUserName',
    value: model['userName'],
  );

  storage.write(
    key: 'profileLastName',
    value: model['lastName'],
  );

  storage.write(
    key: 'referenceShopCode',
    value: model['referenceShopCode'],
  );

  storage.write(
    key: 'referenceShopName',
    value: model['referenceShopName'],
  );

  storage.write(
    key: 'dataUserLoginDDPM',
    value: jsonEncode(model),
  );
}

logout(BuildContext context) async {
  final storage = new FlutterSecureStorage();
  storage.delete(key: 'profileCode10');
  storage.deleteAll();
  var profileCategory = await storage.read(key: 'profileCategory');
  if (profileCategory != '' && profileCategory != null) {
    switch (profileCategory) {
      case 'facebook':
        // logoutFacebook();
        break;
      case 'google':
        logoutGoogle();
        break;
      case 'line':
        logoutLine();
        break;
      default:
    }
  }

  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeMartPage()),
      (Route<dynamic> route) => false);

  // Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (context) => LoginPage()),
  //     (Route<dynamic> route) => false);
}

Future<dynamic> postDio(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode10');
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
    criteria['profileCode'] = profileCode;
  }
  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);

  if (url == server + 'm/goods/read')
    print(response.data['objectData'][0]['priceUsd']);
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioList(String url, List<dynamic> criteria) async {
  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioAny(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode10');
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
    criteria['profileCode'] = profileCode;
  }
  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  // print(response.data['objectData'].toString());
  return Future.value(response.data);
}

Future<dynamic> postDioWithOutProfileCode(String url, dynamic criteria) async {
  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  // print(response.data['objectData'].toString());
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioCategory(String url, dynamic criteria) async {
  print(url);
  print(criteria);
  final storage = new FlutterSecureStorage();
  var platform = Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode10');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];
  list = [...list, ...response.data['objectData']];

  return Future.value(list);
}

Future<dynamic> postDioMessage(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode10');
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }
  Dio dio = new Dio();
  print('-----dio criteria-----' + criteria.toString());
  print('-----dio criteria-----' + url);
  var response = await dio.post(url, data: criteria);
  print('-----dio message-----' + response.data.toString());
  return Future.value(response.data['objectData']);
}

Future<dynamic> postOTPSend(String url, dynamic criteria) async {
  //https://portal-otp.smsmkt.com/api/otp-send
  //https://portal-otp.smsmkt.com/api/otp-validate
  Dio dio = new Dio();
  dio.options.contentType = Headers.formUrlEncodedContentType;
  dio.options.headers["api_key"] = "db88c29e14b65c9db353c9385f6e5f28";
  dio.options.headers["secret_key"] = "XpM2EfFk7DKcyJzt";
  var response = await dio.post(serverOTP + url, data: criteria);
  // print('----------- -----------  ${response.data['result']}');
  return Future.value(response.data['result']);
}

Future<dynamic> postDioCategoryWeMart(String url, dynamic criteria) async {
  // print(url);
  // print(criteria);
  final storage = new FlutterSecureStorage();
  // var platform = Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode16');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  var data = response.data['objectData'];

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];

  list = [...data, ...list];
  return Future.value(list);
}

Future<dynamic> postDioCategoryWeMartNoAll(String url, dynamic criteria) async {
  // print(url);
  // print(criteria);
  final storage = new FlutterSecureStorage();
  // var platform = Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode16');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  var data = response.data['objectData'];

  List<dynamic> list = [
    // {'code': "", 'title': 'ทั้งหมด'}
  ];

  list = [...data];
  return Future.value(list);
}

const splashReadApi = server + 'm/splash/read';
const newsReadApi = server + 'm/news/read';
const profileReadApi = server + 'm/v2/register/read';
const organizationImageReadApi = server + 'm/v2/organization/image/read';
const notificationApi = server + 'm/v2/notification/';
const reporterReadApi = server + 'm/v2/reporter/read';
const newsCommentReadApi = server + 'm/v2/news/comment/';
