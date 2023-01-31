import 'package:flutter/material.dart';

labelTextField(String label, Icon icon) {
  return Row(
    children: <Widget>[
      icon,
      Text(
        ' ' + label,
        style: TextStyle(
          fontSize: 15.000,
          fontFamily: 'Kanit',
        ),
      ),
    ],
  );
}

textField(
  TextEditingController model,
  TextEditingController modelMatch,
  String hintText,
  String validator,
  bool enabled,
  bool isPassword,
) {
  return SizedBox(
    height: 45.0,
    child: TextField(
      // keyboardType: TextInputType.number,
      obscureText: isPassword,
      controller: model,
      enabled: enabled,
      style: TextStyle(
        color: Color(0xFF000070),
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        fontSize: 15.00,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFC5DAFC),
        contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

textFieldLogin({
  TextEditingController model,
  String hintText,
  bool enabled = true,
  bool isPassword = false,
  bool showVisibility = false,
  bool visibility = true,
  Function callback,
  Function onChanged,
}) {
  return SizedBox(
    height: 45.0,
    child: TextField(
        inputFormatters: [
          // fixflutter2 new WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9@_.]")),
        ],
        // keyboardType: TextInputType.number,
        obscureText: isPassword ? visibility : false,
        controller: model,
        onChanged: (String value) {
          onChanged();
        },
        enabled: enabled,
        cursorColor: Color(0xFF1794D2),
        style: TextStyle(
          // color: Colors.white,
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
          fontSize: 15.00,
        ),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            splashColor: Colors.transparent,
            color: Colors.grey,
            icon: isPassword
                ? showVisibility
                    ? visibility
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off)
                    : Icon(Icons.lock)
                : Icon(Icons.person),
            onPressed: () {
              callback();
            },
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            // color: Colors.white70,
            fontFamily: 'Kanit',
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF707070),
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF1794D2),
            ),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF1794D2),
            ),
          ),
        )
        // decoration: InputDecoration(
        //   filled: true,
        //   fillColor: Color(0xFFffffff),
        //   contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        //   hintText: hintText,
        //   border: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(10.0),
        //     borderSide: BorderSide.none,
        //   ),
        // ),
        ),
  );
}
