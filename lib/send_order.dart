import 'package:flutter/material.dart';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class SendOrderPage extends StatefulWidget {
  const SendOrderPage({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _SendOrderPageState createState() => _SendOrderPageState();
}

class _SendOrderPageState extends State<SendOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header2(context, title: 'รายละเอียด'),
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Colors.white,
              child: Row(
                children: [
                  Flexible(
                    child: Align(
                      alignment: Alignment.center,
                      child: StackTap(
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.redAccent.withOpacity(0.5),
                        onTap: () => updateStatus(),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ไปส่งเอง',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Align(
                      alignment: Alignment.center,
                      child: StackTap(
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.redAccent.withOpacity(0.5),
                        onTap: () => updateStatus(),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'มารับที่บ้าน',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildBody() {
    return ListView(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: loadingImageNetwork(widget.model['imageUrl'],
              height: 120, width: 120),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${widget.model['goodsTitle']}',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'ลักษณะสินค้า : ${widget.model['title']}',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'จำนวน : ${widget.model['qty']}',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Text(
            'ที่อยู่จัดส่ง',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${widget.model['consigneeName']} ${widget.model['consigneePhone']}',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${widget.model['address']} ${widget.model['subDistrict']} ${widget.model['district']} \n${widget.model['province']} ${widget.model['postalCode']}',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: 8),
        if (widget.model['discount'] > 0 && widget.model['discount'] != null)
          ..._discount(),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text(
                'เลขสินค้า :',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${widget.model['orderNo']}',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _discount() {
    return <Widget>[
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          'ส่วนลด',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 16,
          ),
        ),
      ),
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          '${widget.model['discount']} ' + widget.model['disCountUnit'] == 'C'
              ? ' บาท'
              : '%',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    ];
  }

  updateStatus() async {
    var status = 'P';
    await postDio('${server}m/cart/order/status/update', {
      'code': widget.model['orderNoReference'],
      'status': status,
    });

    toastFail(context, text: 'ส่งสินค้าสำเร็จ');
  }
}
