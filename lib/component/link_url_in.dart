import 'package:url_launcher/url_launcher.dart';

launchInWebViewWithJavaScript(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      enableJavaScript: true,
    );
  } else {
    print('errror');
    // throw 'Could not launch $url';
  }
}
