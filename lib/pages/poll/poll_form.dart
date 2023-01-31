import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:wereward/component/link_url_out.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wereward/component/button_close_back.dart';
import 'package:wereward/component/gallery_view.dart';
import 'package:wereward/pages/blank_page/blank_loading.dart';
import 'package:wereward/pages/poll/poll_dialog.dart';
import 'package:wereward/pages/poll/poll_list.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/services.dart';
import 'package:wereward/shared/extension.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;

class ListItem {
  int value;
  String name;

  ListItem(this.value, this.name);
}

class PollForm extends StatefulWidget {
  PollForm({
    Key key,
    @required this.code,
    this.model,
    this.url,
    this.titleMenu,
    this.titleHome,
  }) : super(key: key);
  final String code;
  final String url;
  final dynamic model;
  final String titleMenu;
  final String titleHome;

  @override
  _PollDetailPageState createState() => _PollDetailPageState(code: code);
}

class _PollDetailPageState extends State<PollForm> {
  _PollDetailPageState({Key key, this.code});

  List<TextEditingController> _controllers = new List();

  FlutterSecureStorage storage;
  Future<dynamic> _futureModel;
  String code;
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];
  int _selectedIndex;
  int totalAnswer = 1;

  List<List<TextEditingController>> ooo = new List();

  @override
  void initState() {
    storage = FlutterSecureStorage();
    // sharedApi();
    // getUserData();
    _futureModel = postDio(
        '${pollApi}all/read', {'skip': 0, 'limit': 1, 'code': widget.code});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

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
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: FutureBuilder<dynamic>(
            future: _futureModel, // function where you call your api
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              // AsyncSnapshot<Your object type>
              if (snapshot.hasData) {
                List.generate(snapshot.data['questions'].length,
                    (i) => ooo.add(new List<TextEditingController>()));
                return myCard(snapshot.data);
              } else {
                return Container(
                  child: Stack(
                    children: [
                      BlankLoading(),
                      Positioned(
                        right: 0,
                        top: statusBarHeight + 5,
                        child: Container(
                          child: buttonCloseBack(context),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  myCard(dynamic model) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [
      model['imageUrl'] != null ? NetworkImage(model['imageUrl']) : null
    ];
    return Container(
      alignment: Alignment.bottomCenter,
      color: Colors.white,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: false,
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: [
                      Container(
                        // color: Colors.green,
                        padding: EdgeInsets.only(
                          right: 10.0,
                          left: 10.0,
                        ),
                        margin: EdgeInsets.only(right: 50.0, top: 10.0),
                        child: Text(
                          '${model['title']}',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 10,
                              left: 10,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: model['imageUrlCreateBy'] !=
                                          null
                                      ? NetworkImage(model['imageUrlCreateBy'])
                                      : null,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model['createBy'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            dateStringToDate(
                                                    model['createDate']) +
                                                ' | ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          Text(
                                            'เข้าชม ' +
                                                '${model['view']}' +
                                                ' ครั้ง',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Color(0xFFFFFFF),
                        child: GalleryView(
                          imageUrl: [...image, ...urlImage],
                          imageProvider: [...imagePro, ...urlImageProvider],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          right: 10.0,
                          left: 10.0,
                        ),
                        margin: EdgeInsets.only(right: 50.0, top: 10.0),
                        child: Text(
                          '${model['title']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          right: 10,
                          left: 10,
                        ),
                        child: Html(
                          data: model['description'],
                          onLinkTap: (String url, RenderContext context,
                              Map<String, String> attributes, element) {
                            launch(url);
                            // open url in a webview
                          },
                          // onImageTap: (src) {
                          //   // Display the image in large form.
                          // },
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      _listQuestion(model['questions']),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: width * 25 / 100),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Theme.of(context).primaryColorDark,
                            ),
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              onPressed: () {
                                pollReply(model);
                              },
                              child: Text(
                                'ส่ง',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: statusBarHeight + 5,
                    child: Container(
                      child: buttonCloseBack(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // btnPoll(model),
        ],
      ),
    );
  }

  _listQuestion(dynamic model) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: model.length,
        itemBuilder: (context, index) {
          List.generate(model[index]['answers'].length,
              (i) => ooo[index].add(new TextEditingController()));
          return Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: Text(
                  model[index]['isRequired']
                      ? '* ' + model[index]['title']
                      : model[index]['title'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: Text(
                  model[index]['isRequired']
                      ? model[index]['category'] == "single"
                          ? '(กรุณาเลือกคำตอบได้หนึ่งคำตอบ)'
                          : '(กรุณาเลือกคำตอบได้หลายคำตอบ)'
                      : '(ไม่จำเป็นต้องระบุ)',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              _listAnswer(
                  model[index]['answers'], model[index]['category'], index),
              SizedBox(
                height: 10.0,
              ),
            ],
          );
        });
  }

  _listAnswer(dynamic model, String category, int questionIndex) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: model.length,
      itemBuilder: (context, index) {
        return category == 'text'
            ? textBox(ooo[questionIndex][index], model, index)
            : category == 'multiple'
                ? checkBoxMultiple(model, index)
                : checkBoxSingle(model, index);
      },
    );
  }

  textBox(TextEditingController _textEditingController, dynamic item, int i) {
    // print(_textEditingController.text);
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
      child: TextField(
        controller: _textEditingController,
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        maxLength: 300,
        onChanged: (value) => setState(() {
          if (value != '') {
            item[i]['value'] = true;
          } else {
            item[i]['value'] = false;
          }
          item[i]['title'] = _textEditingController.text;
        }),
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.black.withAlpha(50), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), gapPadding: 1),
          hintText: 'แสดงความคิดเห็น',
          contentPadding: const EdgeInsets.all(10.0),
        ),
      ),
    );
  }

  checkBoxSingle(dynamic answers, int i) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 15.0,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColorDark),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
        color: Colors.white,
      ),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          answers[i]['title'],
          style: TextStyle(
            fontSize: 13.0,
            fontFamily: 'Kanit',
            fontWeight: FontWeight.w300,
          ),
        ),
        value: answers[i]['value'],
        onChanged: (bool value) {
          setState(() {
            _selectedIndex = i;
            for (int j = 0; j < answers.length; j++) {
              if (j == _selectedIndex) {
                answers[j]['value'] = !answers[j]['value'];
              } else {
                answers[j]['value'] = false;
              }
            }
          });
        },
        activeColor: Theme.of(context).primaryColorDark,
        checkColor: Colors.white,
      ),
    );
  }

  checkBoxMultiple(dynamic answers, int i) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 15.0,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColorDark),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
        color: Colors.white,
      ),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          answers[i]['title'],
          style: TextStyle(
            fontSize: 13.0,
            fontFamily: 'Kanit',
            fontWeight: FontWeight.w300,
          ),
        ),
        value: answers[i]['value'],
        onChanged: (bool value) {
          setState(() {
            answers[i]['value'] = !answers[i]['value'];
          });
        },
        activeColor: Theme.of(context).primaryColorDark,
        checkColor: Colors.white,
      ),
    );
  }

  pollReply(dynamic model) async {
    String reference = model['code'];
    String title = '';

    bool checkSendReply = true;
    for (int i = 0; i < model['questions'].length; i++) {
      if (model['questions'][i]['isRequired']) {
        List<dynamic> data = model['questions'][i]['answers'];

        var checkValue = data.indexWhere(
          (item) => item['value'] == true && item['value'] != '',
        );

        if (checkValue == -1) {
          checkSendReply = false;
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: new Text(
                    'กรุณาตอบคำถาม',
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
                          color: Color(0xFFFF7514),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
          break;
        } else {
          checkSendReply = true;
        }
      } else {
        checkSendReply = true;
      }
    }

    if (checkSendReply) {
      var value = await storage.read(key: 'dataUserLoginDDPM');
      var user = json.decode(value);

      model['questions']
          .map((question) => {
                title = question['title'],
                reference = question['reference'],
                question['answers']
                    .map((answer) => {
                          if (answer['value'])
                            {
                              postObjectData('m/poll/reply/create', {
                                'reference': reference.toString(),
                                'username': user['username'].toString(),
                                'firstName': user['firstName'].toString(),
                                'lastName': user['lastName'].toString(),
                                'title': title.toString(),
                                'answer': question['reference'] == 'text'
                                    ? answer['value'] == false
                                        ? ''
                                        : answer['value'].toString()
                                    : answer['title'].toString(),
                                'platform': Platform.operatingSystem.toString()
                              })
                            }
                        })
                    .toList(),
              })
          .toList();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PollDialog(
            titleHome: widget.titleHome,
          ),
        ),
      );
      // showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (BuildContext context) => new PollDialog(userData: userData,titleHome: widget.titleHome,),
      // );
    }
  }

  Future<dynamic> readGallery() async {
    final result =
        await postObjectData('m/news/gallery/read', {'code': widget.code});
    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);

        dataPro.add(
            item['imageUrl'] != null ? NetworkImage(item['imageUrl']) : null);
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
  }

  void goBack() async {
    // Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PollList(
          title: widget.titleHome,
        ),
      ),
    );
  }
}
