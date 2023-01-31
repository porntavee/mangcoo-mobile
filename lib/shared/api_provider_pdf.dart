import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ApiServiceProvider {
  // static final String BASE_URL = "https://www.ibm.com/downloads/cas/GJ5QVQ7X";

  static Future<String> loadPDF(String path) async {
    var response = await http.get(Uri.parse(path));

    var dir = await getApplicationDocumentsDirectory();
    File file = new File("${dir.path}/data.pdf");
    file.writeAsBytesSync(response.bodyBytes, flush: true);
    return file.path;
  }

  static Future<dynamic> loadPDFPost(String url, dynamic criteria) async {
    Dio dio = new Dio();
    // print('-----dio criteria-----' + criteria.toString());
    // print('-----dio criteria-----' + url);
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers['Access-Control-Allow-Origin'] = '*';
    dio.options.headers['Access-Control-Allow-Methods'] = 'POST';

    var response = await dio.post(
      url,
      data: criteria,
      onReceiveProgress: showDownloadProgress,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    // var dir = await getApplicationDocumentsDirectory();
    // File file = new File("${dir.path}/data2.pdf");
    // file.writeAsBytesSync(response.data, flush: true);

    return Future.value(response.data);
  }

  static void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }
}
