import 'package:wereward/component/loading_image_network.dart';
import 'package:flutter/material.dart';
import 'package:wereward/shared/api_provider.dart';

class CategorySelector extends StatefulWidget {
  CategorySelector({Key key, this.site, this.model, this.onChange})
      : super(key: key);

//  final VoidCallback onTabCategory;
  final String site;
  final Function(String) onChange;
  final Future<dynamic> model;

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    widget.onChange(snapshot.data[index]['code']);
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color:
                            index == selectedIndex ? Colors.black : Colors.grey,
                        decoration: index == selectedIndex
                            ? TextDecoration.underline
                            : null,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}

class CategorySelector2 extends StatefulWidget {
  CategorySelector2({Key key, this.site, this.model, this.onChange})
      : super(key: key);

//  final VoidCallback onTabCategory;
  final String site;
  final Function(String) onChange;
  final Future<dynamic> model;

  @override
  _CategorySelector2State createState() => _CategorySelector2State();
}

class _CategorySelector2State extends State<CategorySelector2> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 25.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    widget.onChange(snapshot.data[index]['code']);
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 10),
                    decoration: new BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 1,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                      borderRadius: new BorderRadius.circular(12.5),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.0,
                      // vertical: 5.0,
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color: index == selectedIndex
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        // decoration: index == selectedIndex
                        //     ? TextDecoration.underline
                        //     : null,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 25.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}

class CategorySelector3 extends StatefulWidget {
  CategorySelector3({Key key, this.site, this.model, this.onChange})
      : super(key: key);

//  final VoidCallback onTabCategory;
  final String site;
  final Function(String) onChange;
  final Future<dynamic> model;

  @override
  _CategorySelector3State createState() => _CategorySelector3State();
}

class _CategorySelector3State extends State<CategorySelector3> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 55.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    widget.onChange(snapshot.data[index]['code']);
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                      constraints: BoxConstraints(minWidth: 50),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 10),
                      decoration: new BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                        borderRadius: new BorderRadius.circular(12.5),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (snapshot.data[index]['imageUrl'] != null)
                            loadingImageNetwork(
                              snapshot.data[index]['imageUrl'],
                              width: 25,
                              height: 25,
                              color: index == selectedIndex
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                          Text(
                            snapshot.data[index]['title'],
                            style: TextStyle(
                              color: index == selectedIndex
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                              // decoration: index == selectedIndex
                              //     ? TextDecoration.underline
                              //     : null,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1.2,
                              // height: 0.5,
                              fontFamily: 'Kanit',
                            ),
                          )
                        ],
                      )),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 55.0,
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}

class CategorySelector4 extends StatefulWidget {
  CategorySelector4({Key key, this.site, this.model, this.onChange})
      : super(key: key);

//  final VoidCallback onTabCategory;
  final String site;
  final Function(String) onChange;
  final Future<dynamic> model;

  @override
  _CategorySelector4State createState() => _CategorySelector4State();
}

class _CategorySelector4State extends State<CategorySelector4> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 25.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    widget.onChange(snapshot.data[index]['code']);
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 10),
                    decoration: new BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 1,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                      borderRadius: new BorderRadius.circular(12.5),
                      color: index == selectedIndex
                          ? Colors.white
                          : Theme.of(context).accentColor,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.0,
                      // vertical: 5.0,
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color: index == selectedIndex
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        // decoration: index == selectedIndex
                        //     ? TextDecoration.underline
                        //     : null,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 25.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}

class CategorySelector5 extends StatefulWidget {
  CategorySelector5({Key key, this.site, this.model, this.onChange})
      : super(key: key);

//  final VoidCallback onTabCategory;
  final String site;
  final Function(String) onChange;
  final dynamic model;

  @override
  _CategorySelector5State createState() => _CategorySelector5State();
}

class _CategorySelector5State extends State<CategorySelector5> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: double.infinity,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.model.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              widget.onChange(widget.model[index]['code']);
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: index == selectedIndex
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                widget.model[index]['title'],
                style: TextStyle(
                  color: index == selectedIndex
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                  // fontSize: 16.0,
                  // fontWeight: FontWeight.normal,
                  // letterSpacing: 1.2,
                  fontFamily: 'Kanit',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryPrivilegeSpecial extends StatefulWidget {
  CategoryPrivilegeSpecial({
    Key key,
    this.site,
    this.model,
    this.onChange,
    this.path,
    this.code: '',
    this.skip,
    this.limit,
  }) : super(key: key);

//  final VoidCallback onTabCategory;
  final String site;
  final Function(String, String) onChange;
  final Future<dynamic> model;
  final String code;
  final String path;
  final dynamic skip;
  final dynamic limit;

  @override
  _CategoryPrivilegeSpecialState createState() =>
      _CategoryPrivilegeSpecialState();
}

class _CategoryPrivilegeSpecialState extends State<CategoryPrivilegeSpecial> {
  dynamic res;
  String selectedIndex = '';
  String selectedTitleIndex = '';

  @override
  void initState() {
    res = postDioCategoryWeMart(widget.path, {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: res, // function where you call your api\
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.hasData) {
          return Wrap(
            children: snapshot.data
                .map<Widget>(
                  (c) => GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      widget.onChange(c['code'], c['title']);
                      setState(() {
                        selectedIndex = c['code'];
                        selectedTitleIndex = c['title'];
                      });
                    },
                    child: Container(
                      width: 85,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 10, bottom: 10),
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.circular(40),
                        color: c['code'] == selectedIndex
                            ? Color(0xFFFFFFFF).withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Text(
                        c['title'],
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          // decoration: index == selectedIndex
                          //     ? TextDecoration.underline
                          //     : null,
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 1.2,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        } else {
          return Container(
            height: 25.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
