// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class SelectImage extends StatefulWidget {
//   const SelectImage({ Key key }) : super(key: key);

//   @override
//   _SelectImageState createState() => _SelectImageState();
// }

// class _SelectImageState extends State<SelectImage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(

//     );
//   }

//   _imgFromCamera() async {
//     File image = await ImagePicker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 100,
//     );

//     setState(() {
//       _image = image;
//     });
//     _upload();
//   }

//   _imgFromGallery() async {
//     File image = await ImagePicker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 100,
//     );

//     setState(() {
//       _image = image;
//     });
//     _upload();
//   }

//   _imgFromNow() async {
//     setState(() {
//       _imageUrl = _imageUrlSocial;
//     });
//   }

//   void _upload() async {
//     if (_image == null) return;

//     uploadImage(_image).then((res) {
//       setState(() {
//         _imageUrl = res;
//       });
//     }).catchError((err) {
//       print(err);
//     });
//   }

//   void _showPickerImage(context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Container(
//             child: new Wrap(
//               children: <Widget>[
//                 new ListTile(
//                     leading: new Icon(Icons.photo_library),
//                     title: new Text(
//                       'อัลบั้มรูปภาพ',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontFamily: 'Kanit',
//                         fontWeight: FontWeight.normal,
//                       ),
//                     ),
//                     onTap: () {
//                       _imgFromGallery();
//                       Navigator.of(context).pop();
//                     }),
//                 new ListTile(
//                   leading: new Icon(Icons.photo_camera),
//                   title: new Text(
//                     'กล้องถ่ายรูป',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontFamily: 'Kanit',
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   onTap: () {
//                     _imgFromCamera();
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 if (_categorySocial != '')
//                   new ListTile(
//                     leading: new Icon(Icons.photo_library),
//                     title: new Text(
//                       ' ใช้รูปโปรไฟล์จาก ' + _categorySocial,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontFamily: 'Kanit',
//                         fontWeight: FontWeight.normal,
//                       ),
//                     ),
//                     onTap: () {
//                       _imgFromNow();
//                       Navigator.of(context).pop();
//                     },
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

// }
