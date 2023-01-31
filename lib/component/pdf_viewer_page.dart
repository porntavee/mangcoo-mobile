import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:wereward/shared/api_provider_pdf.dart';

class PdfViewerPage extends StatefulWidget {
  PdfViewerPage({Key key, @required this.path}) : super(key: key);

  final String path;

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String localPath;

  int _totalPages = 0;
  // int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    ApiServiceProvider.loadPDF(widget.path).then((value) {
      setState(() {
        localPath = value;
      });
    });

    _loadFile();
  }

  void _loadFile() async {
    await FlutterDownloader.enqueue(
      url: 'your download link',
      savedDir: 'the path of directory where you want to save downloaded files',
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PDF",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
      ),
      body: localPath != null
          ? PDFView(
              filePath: localPath,
              autoSpacing: true,
              enableSwipe: true,
              pageSnap: true,
              nightMode: false,
              onError: (e) {
                print(e);
              },
              onRender: (_pages) {
                setState(() {
                  _totalPages = _pages;
                  pdfReady = true;
                });
              },
              onViewCreated: (PDFViewController vc) {
                _pdfViewController = vc;
              },
              onPageChanged: (int page, int total) {
                setState(() {});
              },
              onPageError: (page, e) {},
            )
          : Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.red)),
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          isLastPage
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.blue,
                  label: Text("first page"),
                  onPressed: () {
                    setState(() {
                      isLastPage = false;
                    });
                    _pdfViewController.setPage(0);
                  },
                )
              : FloatingActionButton.extended(
                  backgroundColor: Colors.blue,
                  label: Text("last page"),
                  onPressed: () {
                    setState(() {
                      isLastPage = true;
                    });
                    _pdfViewController.setPage(_totalPages);
                  },
                )
        ],
      ),
    );
  }
}

class PdfViewerPagePost extends StatefulWidget {
  PdfViewerPagePost({Key key, @required this.path, this.model})
      : super(key: key);

  final String path;
  final dynamic model;

  @override
  _PdfViewerPagePostState createState() => _PdfViewerPagePostState();
}

class _PdfViewerPagePostState extends State<PdfViewerPagePost> {
  String localPath;
  dynamic dataPrint;

  int _totalPages = 0;
  // int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    ApiServiceProvider.loadPDFPost(widget.path, widget.model)
        .then((value) async {
      var dir = await getApplicationDocumentsDirectory();
      File file = new File("${dir.path}/data2.pdf");
      file.writeAsBytesSync(value, flush: true);
      setState(() {
        dataPrint = value;
        localPath = file.path;
      });
    });

    _loadFile();
  }

  void _loadFile() async {
    await FlutterDownloader.enqueue(
      url: 'your download link',
      savedDir: 'the path of directory where you want to save downloaded files',
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PDF",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
      ),
      body: localPath != null
          ? PDFView(
              filePath: localPath,
              autoSpacing: true,
              enableSwipe: true,
              pageSnap: true,
              nightMode: false,
              onError: (e) {
                print(e);
              },
              onRender: (_pages) {
                setState(() {
                  print('------23-sss---------$_pages');
                  _totalPages = _pages;
                  pdfReady = true;
                });
              },
              onViewCreated: (PDFViewController vc) {
                _pdfViewController = vc;
              },
              onPageChanged: (int page, int total) {
                setState(() {});
              },
              onPageError: (page, e) {},
            )
          : Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.red)),
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            backgroundColor: Colors.blue,
            label: Text("Print"),
            onPressed: () async {
              var pdfData = dataPrint;
              await Printing.layoutPdf(onLayout: (format) async => pdfData);
            },
          )
          // isLastPage
          //     ? FloatingActionButton.extended(
          //         backgroundColor: Colors.blue,
          //         label: Text("first page"),
          //         onPressed: () {
          //           setState(() {
          //             isLastPage = false;
          //           });
          //           _pdfViewController.setPage(0);
          //         },
          //       )
          //     : FloatingActionButton.extended(
          //         backgroundColor: Colors.blue,
          //         label: Text("last page"),
          //         onPressed: () {
          //           setState(() {
          //             isLastPage = true;
          //           });
          //           _pdfViewController.setPage((_totalPages - 1));
          //         },
          //       )
        ],
      ),
    );
  }
}
