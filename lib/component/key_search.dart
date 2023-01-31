import 'package:flutter/material.dart';

class KeySearch extends StatefulWidget {
  KeySearch(
      {Key key,
      this.hint: 'อะไรคุณกำลังมองหา',
      this.show,
      this.onKeySearchChange})
      : super(key: key);

//  final VoidCallback onTabCategory;
  final String hint;
  final bool show;
  final Function(String) onKeySearchChange;

  @override
  _SearchBox createState() =>
      _SearchBox(show: show, onKeySearchChange: onKeySearchChange);
}

class _SearchBox extends State<KeySearch> {
  final txtDescription = TextEditingController();
  bool show;
  Function(String) onKeySearchChange;

  _SearchBox({@required this.show, this.onKeySearchChange});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    // double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
        // margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 1,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
          borderRadius: new BorderRadius.circular(15),
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                onKeySearchChange(txtDescription.text);
                setState(() {
                  show = !show;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                width: 30,
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/search.png',
                  height: 20.0,
                  width: 20.0,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 30.0,
                child: TextField(
                  autofocus: false,
                  cursorColor: Colors.blue,
                  controller: txtDescription,
                  onChanged: (text) {
                    if (txtDescription.text == '')
                      onKeySearchChange(txtDescription.text);
                  },
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) {
                    FocusScope.of(context).unfocus();
                    onKeySearchChange(txtDescription.text);
                    setState(() {
                      show = !show;
                    });
                  },
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Kanit',
                  ),
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: widget.hint,
                    contentPadding:
                        const EdgeInsets.only(left: 5.0, right: 5.0),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
