import 'package:flutter/material.dart';
import 'package:wereward/pages/sell/add_option.dart';
import 'package:wereward/shared/extension.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class ListOptionSell extends StatefulWidget {
  const ListOptionSell({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _ListOptionSellState createState() => _ListOptionSellState();
}

class _ListOptionSellState extends State<ListOptionSell> {
  dynamic model;
  bool showDelete = false;

  @override
  void initState() {
    model = widget.model;
    super.initState();
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
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: header2(
          context,
          title: 'เพิ่มตัวเลือกสินค้า',
          customBack: true,
          func: () => Navigator.pop(context, model),
        ),
        body: model.length == 0 ? _buildAddButton() : _buildList(),
      ),
    );
  }

  _buildAddButton() {
    return Center(
      child: StackTap(
        onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddOption()))
            .then((value) =>
                setState(() => {if (value != null) model.add(value)})),
        child: Container(
          height: 40,
          width: 100,
          // alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.red,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text(
              'เพิ่มสินค้า',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildList() {
    return Column(
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 10),
          color: Colors.white,
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => showDelete = !showDelete),
            child: Text(
              showDelete ? 'สำเร็จ' : 'แก้ไข',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            // child: Icon(
            //   Icons.delete_forever,
            //   color: Colors.red,
            //   size: 25,
            // ),
          ),
        ),
        SizedBox(height: 5),
        Expanded(
          child: ListView.separated(
            itemCount: model.length,
            separatorBuilder: (context, index) => SizedBox(height: 3),
            itemBuilder: (context, index) => _buildItem(model[index]),
          ),
        ),
        Container(
          height: 50 + MediaQuery.of(context).padding.bottom,
          color: Colors.white,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8 + MediaQuery.of(context).padding.bottom,
          ),
          child: StackTap(
            onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddOption()))
                .then((value) =>
                    setState(() => {if (value != null) model.add(value)})),
            child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: Text(
                'เพิ่ม',
                style: TextStyle(
                    fontFamily: 'Kanit', fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildItem(item) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddOption(model: item)))
          .then((value) => setState(() => {if (value != null) item = value})),
      child: Container(
        height: 100,
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Image.network(
              item['imageUrl'],
              width: 80,
              height: 80,
            ),
            SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: item['title'] + '\n',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'ราคา : ' +
                          priceFormat.format(item['price']) +
                          '| จำนวน : ' +
                          item['qty'].toString(),
                      // style: TextStyle(),
                    ),
                  ],
                ),
              ),
            ),
            if (showDelete)
              StackTap(
                onTap: () => setState(() =>
                    model.removeWhere((e) => e['title'] == item['title'])),
                child: Container(
                  width: 60,
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Text(
                    'ลบ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
