import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/rendering.dart';
import 'package:wereward/component/material/custom_alert_dialog.dart';
import 'package:wereward/pages/blank_page/toast_fail.dart';
import 'package:wereward/widget/stack_tap.dart';

class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage({Key key, @required this.image}) : super(key: key);

  final String image;

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  GlobalKey globalKey = new GlobalKey();
  bool showLoading = false;

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
        backgroundColor: Colors.black,
        body: GestureDetector(
          // onVerticalDragEnd: (value) => Navigator.pop(context),
          onLongPress: () => _buildDialogSaveImage(),
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(widget.image),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.red,
                      size: 25,
                    ),
                  ),
                ),
              ),
              if (showLoading) _buildshowLoading(),
            ],
          ),
        ),
      ),
    );
  }

  _buildshowLoading() {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        color: Colors.grey.withOpacity(0.8),
        child: CircularProgressIndicator(),
      ),
    );
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    // toastFail(context, text: info);
  }

  _buildDialogSaveImage() async {
    return await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true, // close outside
      context: context,
      builder: (_) {
        return SafeArea(
          child: CustomAlertDialog(
            alignment: Alignment.center,
            height: 40,
            content: StackTap(
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  showLoading = true;
                }),
                _saveNetworkImage(),
              },
              child: new Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  'บันทึกรูปภาพ',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveNetworkImage() async {
    _requestPermission();
    await GallerySaver.saveImage(widget.image, albumName: 'WeMart')
        .then((bool success) {
      toastFail(context, text: 'บันทึกสำเร็จ');
    });
    setState(() {
      showLoading = false;
    });
  }
}
