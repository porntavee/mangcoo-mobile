import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:wereward/widget/stack_tap.dart';

class ImageUploadPicker extends StatefulWidget {
  ImageUploadPicker({Key key, this.onTap, this.child, this.callback})
      : super(key: key);

  final Function() onTap;
  final Function(XFile) callback;
  final Widget child;

  @override
  _ImageUploadPicker createState() => _ImageUploadPicker();
}

class _ImageUploadPicker extends State<ImageUploadPicker>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  dispose() {
    _controller.dispose(); // you need this

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StackTap(
      onTap: () => _showPickerImage(context),
      child: widget.child,
    );
  }

  void _showPickerImage(context) {
    FocusScope.of(context).unfocus();
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

  _imgFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    _upload(image);
  }

  _imgFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    XFile image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) _upload(image);
  }

  void _upload(XFile image) async {
    if (image == null) return;
    widget.callback(image);
    // await uploadImage(image).then((res) {
    //   widget.callback(res);
    // }).catchError((err) {
    //   print(err);
    // });
  }
}
