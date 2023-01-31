import 'package:flutter/material.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({Key key, @required this.model}) : super(key: key);

  final dynamic model;

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController commentController;
  int selectedStar = 0;
  bool showLoading = false;
  @override
  void initState() {
    commentController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: header2(context, title: 'ให้คะแนนสินค้า'),
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
                _buildBodyItem(widget.model),
                Container(height: 1, color: Colors.grey),
                _buildRating(),
                _buildComment()
              ],
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: StackTap(
                  onTap: () => sendReview(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ยืนยัน',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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

  Widget _buildBodyItem(model) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          loadingImageNetwork(
            model['imageUrl'],
            height: 50,
            width: 50,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    model['goodsTitle'],
                    style: TextStyle(
                      color: Color(0xFF0000000),
                      fontFamily: 'Kanit',
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Expanded(
                    child: Text(
                      'ตัวเลือกสินค้า: ' + model['title'].toString(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: 'Kanit',
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Container(
      alignment: Alignment.center,
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [1, 2, 3, 4, 5].map<Widget>((e) => star(e)).toList(),
      ),
    );
  }

  _buildComment() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        // keyboardType: TextInputType.number,
        decoration: InputDecoration(
          fillColor: Colors.grey[200],
          filled: true,
          hintText: "รีวิวสินค้านี้",
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(
              new Radius.circular(5.0),
            ),
          ),
        ),
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 15.0,
          fontFamily: 'Kanit',
        ),
        controller: commentController,
        maxLines: 6,
        maxLength: 1000,
      ),
    );
  }

  star(int index) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedStar = index),
        child: selectedStar == index || selectedStar > index
            ? Image.asset('assets/images/star_full.png')
            : Image.asset('assets/images/star_empty.png'),
      ),
    );
  }

  sendReview() async {
    setState(() => showLoading = true);
    await postDio(server + 'm/goods/comment/create', {
      'description': commentController.text,
      'reference': widget.model['goodsCode'],
      'rating': selectedStar,
      'orderNo': widget.model['orderNo'],
    }).then(
      (value) => {setState(() => showLoading = false), Navigator.pop(context)},
    );
  }
}
