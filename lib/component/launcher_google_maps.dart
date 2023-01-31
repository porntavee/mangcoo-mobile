import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherGoogleMaps extends StatefulWidget {
  @override
  ListState createState() {
    return new ListState();
  }
}

class ListState extends State<LauncherGoogleMaps> {
  static const double lat = 2.813812, long = 101.503413;
  static const String map_api = "API_KEY";

  @override
  Widget build(BuildContext context) {
    //method to launch maps
    void launchMap() async {
      const url =
          "https://maps.google.com/maps/search/?api=$map_api&query=$lat,$long";
      if (await canLaunch(url)) {
        void initState() {
          super.initState();

          canLaunch(
              "https://maps.google.com/maps/search/?api=$map_api&query=$lat,$long");
        }

        await launch(url);
      } else {
        throw 'Could not launch Maps';
      }
    }

    //method to bring out dialog
    void makeDialog() {
      showDialog(
          context: context,
          builder: (_) => new SimpleDialog(
                contentPadding: EdgeInsets.only(left: 30.0, top: 30.0),
                children: <Widget>[
                  new Text(
                    "Address: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  new ButtonBar(
                    children: <Widget>[
                      new IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ],
                  )
                ],
              ));
    }

    return new Scaffold(
      body: new ListView.builder(
        itemBuilder: (context, index) => ExpansionTile(
          title: new Text("State ${index + 1}"),
          children: <Widget>[
            new ListTile(
              title: new Text("Place 1"),
              trailing: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new IconButton(icon: Icon(Icons.info), onPressed: makeDialog),
                  new IconButton(
                      icon: Icon(Icons.directions), onPressed: launchMap)
                ],
              ),
            ),
            new Divider(height: 10.0),
            new ListTile(
              title: new Text("Place 2"),
              trailing: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new IconButton(icon: Icon(Icons.info), onPressed: makeDialog),
                  new IconButton(
                      icon: Icon(Icons.directions), onPressed: launchMap)
                ],
              ),
            )
          ],
        ),
        itemCount: 5,
      ),
    );
  }
}
