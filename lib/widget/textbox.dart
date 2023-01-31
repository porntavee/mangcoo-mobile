import 'package:wereward/widget/text_form_field.dart';
import 'package:flutter/material.dart';

textbox(
    {TextEditingController controller,
    String title = '',
    bool enabled = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      labelTextFormField(title),
      SizedBox(height: 2.0),
      // labelTextFormField('* ชื่อผู้ใช้งาน'),
      textFormField(
        controller,
        null,
        title,
        title,
        enabled,
        false,
        false,
      ),
    ],
  );
}
