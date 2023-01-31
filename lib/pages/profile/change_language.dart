import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wereward/widget/header.dart';
import 'package:wereward/widget/stack_tap.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header2(context, title: tr('chooseLang')),
      body: Column(
        children: [
          StackTap(
            onTap: () => _onChangeLang('th'),
            child: ItemLang(lang: 'th'),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.withOpacity(0.5),
            margin: EdgeInsets.symmetric(vertical: 2),
          ),
          StackTap(
            onTap: () => _onChangeLang('en'),
            child: ItemLang(lang: 'en'),
          ),
        ],
      ),
    );
  }

  _onChangeLang(lang) {
    setState(() {
      if (lang == 'th') {
        context.setLocale(Locale('th'));
      } else {
        context.setLocale(Locale('en'));
      }
    });
  }
}

class ItemLang extends StatelessWidget {
  final lang;

  const ItemLang({
    Key key,
    @required this.lang,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: 50,
          color: Colors.white,
          child: Text(
            lang,
            style: TextStyle(fontSize: 18),
          ).tr(),
        ),
        if (context.locale.languageCode == lang)
          Positioned(
            right: 10,
            child: Image.asset(
              'assets/images/correct.png',
              color: Colors.orange,
              height: 20,
            ),
          )
      ],
    );
  }
}
